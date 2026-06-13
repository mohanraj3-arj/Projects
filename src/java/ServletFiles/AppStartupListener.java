package ServletFiles;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * AppStartupListener
 *
 * Starts MonthlyReportScheduler when Tomcat deploys the app.
 * Stops it cleanly when Tomcat undeploys the app.
 *
 * @WebListener — no web.xml entry needed.
 */
@WebListener
public class AppStartupListener implements ServletContextListener {

    private MonthlyReportScheduler scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[CardManager] App started. Initializing month-end scheduler...");
        scheduler = new MonthlyReportScheduler();
        scheduler.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[CardManager] App stopping. Shutting down scheduler...");
        if (scheduler != null) {
            scheduler.stop();
        }
    }
}