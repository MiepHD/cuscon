package com.froxot.cuscon.licenses;

public class License {

    /*
     * License Checker
     * private static final boolean ENABLE_LICENSE_CHECKER = true; --> enabled
     * Change to private static final boolean ENABLE_LICENSE_CHECKER = false; if you want to disable it
     *
     * NOTE: If you disable license checker you need to remove LICENSE_CHECK permission inside AndroidManifest.xml
     */
    private static final boolean ENABLE_LICENSE_CHECKER = false;

    /*
     * NOTE: If license checker is disabled (above), just ignore this
     *
     * Generate 20 random bytes
     * For easy way, go to https://www.random.org/strings/
     * Set generate 20 random strings
     * Each string should be 2 character long
     * Check numeric digit (0-9)
     * Choose each string should be unique
     * Get string
     */
    private static final byte[] SALT = new byte[]{
            //Put generated random bytes below, separate with comma, ex: 14, 23, 58, 85, ...

    };

}
