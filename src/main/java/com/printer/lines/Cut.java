package com.printer.lines;

import com.printer.Line;
import com.printer.LineType;
import com.printer.PageWidth;

public class Cut extends Line {
    public Cut() {
        super(LineType.CUT);
    }

    @Override
    public byte[] build(PageWidth pageWidth) {
        return new byte[]{(byte) 0x1B, (byte) 0x6D};
    }
} 