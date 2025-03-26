package com.printer;

import java.util.List;

public enum LineType {
    TEXT,
    CUT,
    BARCODE,
    DIVIDER,
    CASH_BOX,
    NEWLINE,
    MULTI_TEXT,
    TEXT_SPAN
}

public enum Align {
    LEFT,
    CENTER,
    RIGHT
}

public abstract class Line {
    protected final LineType type;

    protected Line(LineType type) {
        this.type = type;
    }

    public abstract byte[] build(PageWidth pageWidth);
} 