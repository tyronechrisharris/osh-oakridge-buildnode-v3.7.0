package org.sensorhub.ui;

import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import com.vaadin.server.VaadinSession;

public class TranslationUtils {

    public static String trans(String key, String defaultText) {
        Locale currentLocale = Locale.ENGLISH;
        try {
            VaadinSession session = VaadinSession.getCurrent();
            if (session != null) {
                Locale sessionLocale = (Locale) session.getAttribute("language");
                if (sessionLocale != null) {
                    currentLocale = sessionLocale;
                }
            }
            ResourceBundle bundle = ResourceBundle.getBundle("org.sensorhub.ui.messages", currentLocale);
            if (bundle.containsKey(key)) {
                return bundle.getString(key);
            } else {
                return defaultText;
            }
        } catch (MissingResourceException | IllegalStateException | NullPointerException e) {
            return defaultText;
        }
    }

    public static String transArgs(String key, String defaultText, Object... args) {
        String template = trans(key, defaultText);
        return java.text.MessageFormat.format(template, args);
    }
}
