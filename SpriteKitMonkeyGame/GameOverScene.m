//
//  GameOverScene.m
//  SpriteKitMonkeyGame
//
//  Created by Asmaa Elkeurti on 3/24/14.
//  Copyright (c) 2014 Asmaa Elkeurti. All rights reserved.
//


#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size won:(BOOL)won {
    if (self = [super initWithSize:size]) {
        // 1
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2
        NSString * message;
        if (won) {
            message = @"You win!";
        } else {
            message = @"Sorry, you lose";
        }
        
        // 3
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        // 4
        [self runAction:
         [SKAction sequence:@[
                              [SKAction waitForDuration:3.0],
                              [SKAction runBlock:^{
             // 5
             SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
             SKScene * myScene = [[MyScene alloc] initWithSize:self.size];
             [self.view presentScene:myScene transition: reveal];
         }]
                              ]]
         ];
        
    }
    return self;
}

@end