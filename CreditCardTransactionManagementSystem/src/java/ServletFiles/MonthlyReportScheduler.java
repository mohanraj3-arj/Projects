package ServletFiles;

import util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

/**
 * MonthlyReportScheduler
 *
 * Background scheduler — runs every day at 23:30.
 * On the LAST day of the month, emails every user their monthly PDF report.
 * Started and stopped automatically by AppStartupListener.
 */
public class MonthlyReportScheduler {

    private final ScheduledExecutorService scheduler =
            Executors.newSingleThreadScheduledExecutor(r -> {
                Thread t = new Thread(r, "cardmanager-monthly-scheduler");
                t.setDaemon(true);  // won't block Tomcat shutdown
                return t;
            });

    private ScheduledFuture<?> task;

    // ── Start — called by AppStartupListener on app deploy ───────────────────
    public void start() {
        long initialDelay = secondsUntilNextRun(23, 30);

        System.out.println("[CardManager Scheduler] Started. " +
                "First check in " + (initialDelay / 60) + " minutes at 23:30.");

        // Runs once every 24 hours, first run at next 23:30
        task = scheduler.scheduleAtFixedRate(
                this::runDailyCheck,
                initialDelay,
                TimeUnit.DAYS.toSeconds(1),
                TimeUnit.SECONDS);
    }

    // ── Stop — called by AppStartupListener on app undeploy ─────────────────
    public void stop() {
        if (task != null) {
            task.cancel(false);
        }
        scheduler.shutdown();
        System.out.println("[CardManager Scheduler] Stopped cleanly.");
    }

    // ── Daily check at 23:30 — only sends on last day of month ──────────────
    private void runDailyCheck() {
        LocalDate today   = LocalDate.now();
        LocalDate lastDay = YearMonth.from(today).atEndOfMonth();

        System.out.println("[CardManager Scheduler] Daily check: " + today +
                " | Month-end: " + lastDay);

        if (!today.equals(lastDay)) {
            System.out.println("[CardManager Scheduler] Not month-end — skipping.");
            return;
        }

        System.out.println("[CardManager Scheduler] MONTH-END! Sending reports...");
        sendToAllUsers(today);
    }

    // ── Fetch all users and send each their PDF report ───────────────────────
    private void sendToAllUsers(LocalDate reportDate) {
        List<UserRecord> users = new ArrayList<>();

        // Fetch all users first, close DB, then email
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                    "SELECT user_id, user_name, email FROM users");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                users.add(new UserRecord(
                        rs.getInt("user_id"),
                        rs.getString("user_name"),
                        rs.getString("email")));
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            System.err.println("[CardManager Scheduler] DB error: " + e.getMessage());
            e.printStackTrace();
            return;
        }

        System.out.println("[CardManager Scheduler] Sending to " +
                users.size() + " user(s).");

        String monthLabel = reportDate.format(DateTimeFormatter.ofPattern("MMMM yyyy"));
        String filename   = "CardManager_Report_" +
                reportDate.format(DateTimeFormatter.ofPattern("MMMM_yyyy")) + ".pdf";

        for (UserRecord user : users) {
            try {
                // Fresh connection per user — one failure won't block others
                byte[] pdfBytes;
                try (Connection con = DBConnection.getConnection()) {
                    // Calls public static method from MonthlyReportServlet
                    pdfBytes = MonthlyReportServlet.buildMonthlyPdf(
                            con, user.userId, user.userName, reportDate, true);
                }

                // Calls public static method from MonthlyReportServlet
                MonthlyReportServlet.sendReportEmail(
                        user.email, user.userName, monthLabel, pdfBytes, filename);

                System.out.println("[CardManager Scheduler] Sent to: " + user.email);

            } catch (Exception e) {
                // Log and continue — don't let one user's failure stop others
                System.err.println("[CardManager Scheduler] Failed for user " +
                        user.userId + " (" + user.email + "): " + e.getMessage());
                e.printStackTrace();
            }
        }

        System.out.println("[CardManager Scheduler] Month-end send complete.");
    }

    // ── Calculate seconds from now until next HH:MM ──────────────────────────
    private long secondsUntilNextRun(int hour, int minute) {
        java.time.LocalDateTime now  = java.time.LocalDateTime.now();
        java.time.LocalDateTime next = now.toLocalDate()
                .atTime(java.time.LocalTime.of(hour, minute, 0));

        if (!now.isBefore(next)) {
            next = next.plusDays(1);
        }

        return java.time.Duration.between(now, next).getSeconds();
    }

    // ── Inner class to hold user data ────────────────────────────────────────
    private static class UserRecord {
        final int    userId;
        final String userName;
        final String email;

        UserRecord(int userId, String userName, String email) {
            this.userId   = userId;
            this.userName = userName;
            this.email    = email;
        }
    }
}