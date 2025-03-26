package com.printer.lines;

import com.printer.Align;
import com.printer.Line;
import com.printer.LineType;
import com.printer.PageWidth;

public class Divider extends Line {
    private final String character;

    public Divider(String character) {
        super(LineType.DIVIDER);
        this.character = character;
    }

    public Divider() {
        this("-");
    }

    @Override
    public byte[] build(PageWidth pageWidth) {
        List<Byte> res = new ArrayList<>();
        res.add((byte) 0x1B);
        res.add((byte) 0x45);
        res.add((byte) 0x00);
        res.add((byte) 0x1D);
        res.add((byte) 0x21);
        res.add((byte) 0x00);

        byte charByte = 0x2D;
        if (!character.isEmpty()) {
            charByte = character.getBytes()[0];
        }

        int width = pageWidth == PageWidth.P80 ? 48 : 32;
        for (int j = 0; j < width; j++) {
            res.add(charByte);
        }
        res.add((byte) 0x0A);

        byte[] result = new byte[res.size()];
        for (int i = 0; i < res.size(); i++) {
            result[i] = res.get(i);
        }
        return result;
    }
} 