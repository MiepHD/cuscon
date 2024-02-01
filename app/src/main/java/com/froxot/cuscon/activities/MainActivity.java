package com.froxot.cuscon.activities;

import androidx.annotation.NonNull;

import candybar.lib.activities.CandyBarMainActivity;

import com.froxot.cuscon.licenses.License;

public class MainActivity extends CandyBarMainActivity {

    @NonNull
    @Override
    public ActivityConfiguration onInit() {
        return new ActivityConfiguration();
    }
}
