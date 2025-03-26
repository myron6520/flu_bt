package com.printer.lines;

import com.printer.Line;
import com.printer.LineType;
import com.printer.PageWidth;

public class CashBox extends Line {
    public CashBox() {
        super(LineType.CASH_BOX);
    }

    @Override
    public byte[] build(PageWidth pageWidth) {
        return new byte[]{
            (byte) 0x1B, (byte) 0x70,
            (byte) 0x00, (byte) 0x30,
            (byte) 0xFF
        };
    }
} 