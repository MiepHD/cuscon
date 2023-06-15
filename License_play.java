package com.froxot.cuscon.licenses;

import candybar.lib.items.InAppBilling;

public class License {
    private static final boolean ENABLE_LICENSE_CHECKER = false;
    private static final byte[] SALT = new byte[]{};

    /*
     * Your license key
     * If your app hasn't published at play store, publish it first as beta, get license key
     */
    private static final String LICENSE_KEY = "YOUR LICENSE KEY";

    /*
     * NOTE: Make sure your app name in project same as app name at play store listing
     * NOTE: Your InApp Purchase will works only after the apk published
     *
     * InApp product id for premium request
     * Product name displayed the same as product name displayed at play store
     * So make sure to name it properly, like include number of icons
     * Format: new InAppBilling("premium request product id", number of icons)
     */
    private static final InAppBilling[] PREMIUM_REQUEST_PRODUCTS = new InAppBilling[]{
            new InAppBilling("cuscon.prequest.two", 2),
            new InAppBilling("cuscon.prequest.4", 4),
            new InAppBilling("cuscon.prequest.6", 6),
            new InAppBilling("cuscon.prequest.8", 8),
            new InAppBilling("cuscon.prequest.10", 10)
    };

    /*
     * NOTE: If donation disabled, just ignored this
     *
     * InApp product id for donation
     * Product name displayed the same as product name displayed at play store
     * So make sure to name it properly
     * Format: new InAppBilling("donation product id")
     */
    private static final InAppBilling[] DONATION_PRODUCT = new InAppBilling[]{
            new InAppBilling("cuscon.donation.1"),
            new InAppBilling("cuscon.donation.2"),
            new InAppBilling("cuscon.donation.3")
    };

    public static boolean isLicenseCheckerEnabled() {
        return ENABLE_LICENSE_CHECKER;
    }

    public static String getLicenseKey() {
        return LICENSE_KEY;
    }

    public static byte[] getRandomString() {
        return SALT;
    }

    public static String[] getPremiumRequestProductsId() {
        String[] productId = new String[PREMIUM_REQUEST_PRODUCTS.length];
        for (int i = 0; i < PREMIUM_REQUEST_PRODUCTS.length; i++) {
            productId[i] = PREMIUM_REQUEST_PRODUCTS[i].getProductId();
        }
        return productId;
    }

    public static int[] getPremiumRequestProductsCount() {
        int[] productCount = new int[PREMIUM_REQUEST_PRODUCTS.length];
        for (int i = 0; i < PREMIUM_REQUEST_PRODUCTS.length; i++) {
            productCount[i] = PREMIUM_REQUEST_PRODUCTS[i].getProductCount();
        }
        return productCount;
    }

    public static String[] getDonationProductsId() {
        String[] productId = new String[DONATION_PRODUCT.length];
        for (int i = 0; i < DONATION_PRODUCT.length; i++) {
            productId[i] = DONATION_PRODUCT[i].getProductId();
        }
        return productId;
    }

}
