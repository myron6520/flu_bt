package com.printer;

public enum PageWidth {
    P58(58),
    P80(80);

    private final int width;

    PageWidth(int width) {
        this.width = width;
    }

    public int getWidth() {
        return width;
    }

    public static PageWidth fromInt(int width) {
        switch (width) {
            case 58:
                return P58;
            case 80:
                return P80;
            default:
                return null;
        }
    }
} 