package com.printer.lines;

import com.printer.Align;
import com.printer.Line;
import com.printer.LineType;
import com.printer.PageWidth;

import java.util.ArrayList;
import java.util.List;

public class Barcode extends Line {
    private final Align align;
    private final int height;
    private final int lineWidth;
    private final boolean isShowText;
    private final String content;
    private final boolean needCodeB;

    public Barcode(String content, Align align, int height, int lineWidth, boolean isShowText, boolean needCodeB) {
        super(LineType.BARCODE);
        this.content = content;
        this.align = align;
        this.height = height;
        this.lineWidth = lineWidth;
        this.isShowText = isShowText;
        this.needCodeB = needCodeB;
    }

    public Barcode(String content) {
        this(content, Align.CENTER, 3 * 24, 1, true, false);
    }

    @Override
    public byte[] build(PageWidth pageWidth) {
        List<Byte> res = new ArrayList<>();
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

        res.add((byte) 0x1D);
        res.add((byte) 0x68);
        res.add((byte) height);
        
        if (isShowText) {
            res.add((byte) 0x1D);
            res.add((byte) 0x48);
            res.add((byte) 0x02);
        }
        
        res.add((byte) 0x1D);
        res.add((byte) 0x77);
        res.add((byte) lineWidth);

        res.add((byte) 0x1D);
        res.add((byte) 0x6B);
        res.add((byte) 0x49);
        
        String barcodeContent = needCodeB ? "{B" + content : content;
        res.addAll(convertStringToBytes(barcodeContent));
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