package com.printer.lines;

import com.printer.Align;

public class TextSpan {
    private final String text;
    private final Align align;
    private final int width;
    private final int flex;

    public TextSpan(String text, Align align, int width, int flex) {
        this.text = text;
        this.align = align;
        this.width = width;
        this.flex = flex;
    }

    public TextSpan(String text) {
        this(text, Align.LEFT, 0, 0);
    }

    public String getText() {
        return text;
    }

    public Align getAlign() {
        return align;
    }

    public int getWidth() {
        return width;
    }

    public int getFlex() {
        return flex;
    }
} 