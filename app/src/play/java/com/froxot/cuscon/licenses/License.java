package com.froxot.cuscon.licenses;

import candybar.lib.items.InAppBilling;

public class License {
    private static final boolean ENABLE_LICENSE_CHECKER = false;
    private static final byte[] SALT = new byte[]{};

    private static final String LICENSE_KEY = "YOUR LICENSE KEY";

    private static final InAppBilling[] PREMIUM_REQUEST_PRODUCTS = new InAppBilling[]{
            new InAppBilling("cuscon.request.2", 2),
            new InAppBilling("cuscon.request.4", 4),
            new InAppBilling("cuscon.request.6", 6),
            new InAppBilling("cuscon.request.8", 8),
            new InAppBilling("cuscon.request.10", 10)
    };

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
