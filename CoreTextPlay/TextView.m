//
//  TextView.m
//  CoreTextPlay
//
//  Created by Donny Kurniawan on 9/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TextView.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@implementation TextView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
//        self.layer.geometryFlipped = YES;
    }
    return self;
}

#pragma mark - Miscellaneous

- (void)enumerateLinesInFrame:(CTFrameRef)frame usingBlock:(void (^)(CTLineRef line, CGPoint lineOrigin, NSRange strRange, BOOL *stop))block
{
    NSArray *lines = (NSArray *)CTFrameGetLines(frame);
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, lines.count), origins);
    
    for (int i = 0; i < lines.count; i++) {
        CTLineRef argLine = (CTLineRef)[lines objectAtIndex:i];
        CGPoint argLineOrigin = origins[i];
        CFRange strR = CTLineGetStringRange(argLine);
        NSRange argStrRange = NSMakeRange(strR.location == kCFNotFound ? NSNotFound : strR.location, strR.length);
        BOOL stopBlock = NO;
        
        block(argLine, argLineOrigin, argStrRange, &stopBlock);
        
        if (stopBlock)
            break;
    }
}

#pragma mark - View

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];    
    
    // Create the string
    
	NSString *string = @"The quick brown fox jumps over the lazy dog!\nThe quick brown fox jumps over the lazy dog!";    
	CTFontRef strFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 24.0, NULL);
	CGColorRef strColor = [UIColor blueColor].CGColor;
	NSNumber *strUnderline = [NSNumber numberWithInt:kCTUnderlineStyleSingle];
    
	NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)strFont, (id)kCTFontAttributeName, strColor, (id)kCTForegroundColorAttributeName, strUnderline, (id)kCTUnderlineStyleAttributeName, nil];
    
	NSAttributedString *stringToDraw = [[[NSAttributedString alloc] initWithString:string attributes:attrDict] autorelease];
    
    CFRelease(strFont);



    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    // Or, we can flip the geometry in initWithCoder:
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
        
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)stringToDraw);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [stringToDraw length]), path, NULL);


    [self enumerateLinesInFrame:frame usingBlock:^(CTLineRef line, CGPoint lineOrigin, NSRange strRange, BOOL *stop) {
        
        CGFloat strOffsetStart = CTLineGetOffsetForStringIndex(line, strRange.location, NULL);
        CGFloat strOffsetEnd = CTLineGetOffsetForStringIndex(line, strRange.location + strRange.length, NULL);
        
        NSLog(@"lineOrigin:%@", NSStringFromCGPoint(lineOrigin));
        NSLog(@"strRange:%@", NSStringFromRange(strRange));        
        NSLog(@"strOffsetStart:%f strOffsetEnd:%f", strOffsetStart, strOffsetEnd);
        
        CGFloat ascent, descent;
        CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
        
        NSLog(@"ascent:%f descent:%f", ascent, descent);
        
        CGRect imageBound = CTLineGetImageBounds(line, context);
        imageBound.origin.x += lineOrigin.x;
        imageBound.origin.y += lineOrigin.y;
        
        NSLog(@"imageBound:%@", NSStringFromCGRect(imageBound));

        
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        
        // We need to modify the y coordinate by descent
        CGContextAddRect(context, CGRectMake(strOffsetStart, lineOrigin.y - descent, strOffsetEnd - strOffsetStart, ascent + descent));

        CGContextStrokePath(context);

        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);

        CGContextAddRect(context, imageBound);
        CGContextStrokePath(context);
    }];
    
    
    CTFrameDraw(frame, context);
    
    
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(path);
}

@end
