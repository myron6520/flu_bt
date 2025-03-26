package com.printer.lines;

import com.printer.Align;
import com.printer.Line;
import com.printer.LineType;
import com.printer.PageWidth;

import java.util.ArrayList;
import java.util.List;

public class MultiText extends Line {
    private final List<TextSpan> spans;
    private final int weight;
    private final int size;
    private final int bold;

    public MultiText(List<TextSpan> spans, int weight, int size, int bold) {
        super(LineType.MULTI_TEXT);
        this.spans = spans;
        this.weight = weight;
        this.size = size;
        this.bold = bold;
    }

    public MultiText(List<TextSpan> spans) {
        this(spans, 0, 0, 0);
    }

    @Override
    public byte[] build(PageWidth pageWidth) {
        int total = calculateTotalWidth(pageWidth);
        StringBuilder text = new StringBuilder();
        int totalFlex = 0;
        int totalWidth = 0;

        // Calculate total flex and width
        for (TextSpan span : spans) {
            totalFlex += span.getWidth() <= 0 ? span.getFlex() : 0;
            totalWidth += span.getWidth() <= 0 ? 0 : span.getWidth();
        }

        // Build the text with proper spacing
        for (TextSpan span : spans) {
            int width = span.getWidth();
            if (width == 0) {
                double ratio = (double) span.getFlex() / totalFlex;
                width = (int) ((total - totalWidth) * ratio);
            }

            if (span.getText().length() > width) {
                text.append(span.getText());
            } else {
                int white = width - span.getText().length();
                switch (span.getAlign()) {
                    case LEFT:
                        text.append(span.getText()).append(repeat(" ", white));
                        break;
                    case CENTER:
                        int len = Math.max(white / 2, 1);
                        text.append(repeat(" ", len))
                            .append(span.getText())
                            .append(repeat(" ", len));
                        break;
                    case RIGHT:
                        text.append(repeat(" ", white)).append(span.getText());
                        break;
                }
            }
        }

        // Create a Text line with the formatted text
        Text textLine = new Text(text.toString(), Align.LEFT, size, bold, weight);
        return textLine.build(pageWidth);
    }

    private int calculateTotalWidth(PageWidth pageWidth) {
        int total = 32;
        if (pageWidth == PageWidth.P80) {
            total = 48;
        }

        switch (weight) {
            case 1:
                total /= 2;
                break;
            case 2:
                total /= 4;
                break;
        }

        return total;
    }

    private String repeat(String str, int times) {
        return str.repeat(times);
    }
} 