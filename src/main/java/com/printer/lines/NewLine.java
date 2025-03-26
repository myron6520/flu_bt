package com.printer.lines;

import com.printer.Line;
import com.printer.LineType;
import com.printer.PageWidth;

public class NewLine extends Line {
    public NewLine() {
        super(LineType.NEWLINE);
    }

    @Override
    public byte[] build(PageWidth pageWidth) {
        return new byte[]{
            (byte) 0x1B, (byte) 0x45, (byte) 0x00,
            (byte) 0x1D, (byte) 0x21, (byte) 0x00,
            (byte) 0x0A
        };
    }
} 