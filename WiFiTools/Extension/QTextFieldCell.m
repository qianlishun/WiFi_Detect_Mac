//
//  QTextFieldCell.m
//  WiFiTools
//
//  Created by Qianlishun on 2022/3/31.
//

#import "QTextFieldCell.h"

@implementation QTextFieldCell

- (NSRect)drawingRectForBounds:(NSRect)rect{
    NSRect newRect = [super drawingRectForBounds:rect];
    NSSize textSize = self.cellSize;
    CGFloat heightDelta = newRect.size.height - textSize.height;
    if(heightDelta > 0){
        newRect.size.height = textSize.height;
        newRect.origin.y += heightDelta * 0.5;
    }
    return newRect;
}

@end
