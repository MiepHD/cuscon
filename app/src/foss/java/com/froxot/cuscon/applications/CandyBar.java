package com.froxot.cuscon.applications;

import androidx.annotation.NonNull;

// TODO: Remove `//` below to enable OneSignal
//import com.onesignal.OneSignal;

import com.froxot.cuscon.R;

import candybar.lib.applications.CandyBarApplication;

public class CandyBar extends CandyBarApplication {

    // TODO: Remove `/*` and `*/` below to enable OneSignal
    /*
    @Override
    public void onCreate() {
        super.onCreate();

        // OneSignal Initialization
        OneSignal.initWithContext(this);
        OneSignal.setAppId("YOUR_ONESIGNAL_APP_ID_HERE");
    }
    */

    @NonNull
    @Override
    public Class<?> getDrawableClass() {
        return R.drawable.class;
    }

    @NonNull
    @Override
    public Configuration onInit() {
        // Sample configuration
        Configuration configuration = new Configuration();

        configuration.setGenerateAppFilter(true);
        configuration.setGenerateAppMap(false);
        configuration.setGenerateThemeResources(true);
        configuration.setDonationLinks(new DonationLink[] {
            new DonationLink(
                    "buy_me_a_coffee",
                    "Buy Me a Coffee",
                    "Send me tips on Buy Me a Coffee so I can buy me a hot chocolate",
                    "https://www.buymeacoffee.com/yazazuyo"),
            new DonationLink(
                    // You can use png file (without extension) inside drawable-nodpi folder or url
                    "ko_fi",
                    "Ko-fi",
                    "Send me tips on on Ko-fi",
                    "https://ko-fi.com/yazazuyo")
        });

        return configuration;
    }
}
