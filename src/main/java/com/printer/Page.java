package com.printer;

import java.util.ArrayList;
import java.util.List;

public class Page {
    private final PageWidth pageWidth;
    private final List<Line> lines;

    public Page(PageWidth pageWidth) {
        this.pageWidth = pageWidth;
        this.lines = new ArrayList<>();
    }

    public byte[] build() {
        List<Byte> content = new ArrayList<>();
        for (Line line : lines) {
            byte[] lineBytes = line.build(pageWidth);
            for (byte b : lineBytes) {
                content.add(b);
            }
        }
        byte[] result = new byte[content.size()];
        for (int i = 0; i < content.size(); i++) {
            result[i] = content.get(i);
        }
        return result;
    }

    public void addLine(Line line) {
        lines.add(line);
    }

    public void addLines(List<Line> lines) {
        this.lines.addAll(lines);
    }
} 