package com.froxot.cuscon.licenses;

public class License {
    private static final boolean ENABLE_LICENSE_CHECKER = false;
    private static final byte[] SALT = new byte[]{};

    /*
     * Your license key
     * If your app hasn't published at play store, publish it first as beta, get license key
     */
    private static final String LICENSE_KEY = "YOUR LICENSE KEY";

    public static boolean isLicenseCheckerEnabled() {
        return ENABLE_LICENSE_CHECKER;
    }

    public static String getLicenseKey() {
        return LICENSE_KEY;
    }

    public static byte[] getRandomString() {
        return SALT;
    }

}
