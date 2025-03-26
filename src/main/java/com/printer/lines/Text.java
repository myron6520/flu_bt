package com.printer.lines;

import com.printer.Align;
import com.printer.Line;
import com.printer.LineType;
import com.printer.PageWidth;

import java.util.ArrayList;
import java.util.List;

public class Text extends Line {
    private final String text;
    private final Align align;
    private final int size;
    private final int bold;
    private final int weight;

    public Text(String text, Align align, int size, int bold, int weight) {
        super(LineType.TEXT);
        this.text = text;
        this.align = align;
        this.size = size;
        this.bold = bold;
        this.weight = weight;
    }

    public Text(String text) {
        this(text, Align.LEFT, 0, 0, 0);
    }

    @Override
    public byte[] build(PageWidth pageWidth) {
        List<Byte> res = new ArrayList<>();
        res.add((byte) 0x1B);
        res.add((byte) 0x45);
        res.add((byte) (bold == 1 ? 0x01 : 0x00));
        res.add((byte) 0x1D);
        res.add((byte) 0x21);
        res.add((byte) ((weight << 4 & 0xFF) | size));
        res.add((byte) 0x1B);
        res.add((byte) 0x61);
        
        switch (align) {
            case LEFT:
                res.add((byte) 0x00);
                break;
            case CENTER:
                res.add((byte) 0x01);
                break;
            case RIGHT:
                res.add((byte) 0x02);
                break;
        }
        
        res.addAll(convertStringToBytes(text));
        res.add((byte) 0x0A);

        byte[] result = new byte[res.size()];
        for (int i = 0; i < res.size(); i++) {
            result[i] = res.get(i);
        }
        return result;
    }

    private List<Byte> convertStringToBytes(String str) {
        List<Byte> bytes = new ArrayList<>();
        for (byte b : str.getBytes()) {
            bytes.add(b);
        }
        return bytes;
    }
} 