//
//  MyScene.m
//  SpriteKitMonkeyGame
//
//  Created by Asmaa Elkeurti on 3/23/14.
//  Copyright (c) 2014 Asmaa Elkeurti. All rights reserved.
//



//DISCLAIMER: Not all parts of this is my original work, some of this code was taken from various Ray Wenderleich Sprite Kit tutorials, as well as stack overflow questions similar to the ones I was had


#import "MyScene.h"
#import "GameOverScene.h"
@interface MyScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monkeysDestroyed;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) NSUInteger score;
@property (strong, nonatomic) SKLabelNode *highScoreLabel;
@property (nonatomic) NSUInteger highScore;
@property (nonatomic) NSUInteger remainingLives;
@property (strong,nonatomic) SKLabelNode *remainingLivesLabel;
@end

@implementation MyScene


static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monkeyCategory        =  0x1 << 1;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 3
        self.backgroundColor = [SKColor greenColor];
        
        // 4
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"indianajones"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        [self addChild:self.player];
    }
    
    SKSpriteNode *tree = [SKSpriteNode spriteNodeWithImageNamed:@"trees"];
    tree.position = CGPointMake(self.frame.size.width-20, 20);
    SKSpriteNode *tree2 = [SKSpriteNode spriteNodeWithImageNamed:@"trees"];
    tree2.position = CGPointMake(self.frame.size.width-20, 65);
    SKSpriteNode *tree3 = [SKSpriteNode spriteNodeWithImageNamed:@"trees"];
    tree3.position = CGPointMake(self.frame.size.width-20, 110);
    SKSpriteNode *tree4 = [SKSpriteNode spriteNodeWithImageNamed:@"trees"];
    tree4.position = CGPointMake(self.frame.size.width-20, 150);
    SKSpriteNode *tree5 = [SKSpriteNode spriteNodeWithImageNamed:@"trees"];
    tree5.position = CGPointMake(self.frame.size.width-20, 200);
    SKSpriteNode *tree6 = [SKSpriteNode spriteNodeWithImageNamed:@"trees"];
    tree6.position = CGPointMake(self.frame.size.width-20, self.frame.size.height-30);
    SKSpriteNode *tree7 = [SKSpriteNode spriteNodeWithImageNamed:@"trees"];
    tree7.position = CGPointMake(self.frame.size.width-20, self.frame.size.height-80);
    [self addChild:tree];
    [self addChild:tree2];
    [self addChild:tree3];
    [self addChild:tree4];
    [self addChild:tree5];
    [self addChild:tree6];
    [self addChild:tree7];
    
    
    
    
    
    float margin = 10;
    if (self.scoreLabel == nil) {
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.scoreLabel.text = @"Score: 0";
        self.scoreLabel.fontSize = 14;
        self.scoreLabel.zPosition = 4;
        self.scoreLabel.fontColor = [SKColor blackColor];
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.scoreLabel.position = CGPointMake(margin, margin);
        [self addChild:self.scoreLabel];
    }
    self.physicsWorld.contactDelegate = self;
    return self;
}

-(void)addMonkey {
    
    SKSpriteNode *monkey = [SKSpriteNode spriteNodeWithImageNamed:@"EvilMonkey"];
    
    // Determine where to spawn monkey along Y axis
    int minY = monkey.size.height / 2;
    int maxY = self.frame.size.height - monkey.size.height /2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() %rangeY) + minY;
    
    monkey.position = CGPointMake(self.frame.size.width + monkey.size.width/2, actualY);
    [self addChild:monkey];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDruation = (arc4random() %rangeDuration) + minDuration;
    
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-monkey.size.width/2, actualY) duration:actualDruation];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
        
    }];
    [monkey runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
    
    monkey.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monkey.size]; // 1
    monkey.physicsBody.dynamic = YES; // physics engine does not control movements, movements are controlled through code we've already written
    monkey.physicsBody.categoryBitMask = monkeyCategory; // 3
    monkey.physicsBody.contactTestBitMask = projectileCategory; // 4
    monkey.physicsBody.collisionBitMask = 0; // we don't want monkeys and projectiles to bounce off of eachother
    monkey.physicsBody.affectedByGravity = NO;
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonkey];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"banana"];
    projectile.position = self.player.position;
    
    CGPoint offset = rwSub(location, projectile.position);
    
    if (offset.x <= 0) return;
    
    [self addChild:projectile];
    
    CGPoint direction = rwNormalize(offset);
    
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monkeyCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    projectile.physicsBody.affectedByGravity = NO;
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithmonkey:(SKSpriteNode *)monkey {
    NSLog(@"Hit");
    SKSpriteNode *newMonkey = [SKSpriteNode spriteNodeWithImageNamed:@"HappyMonkey"];
    newMonkey.position = monkey.position;
    [self addChild:newMonkey];
    newMonkey.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newMonkey.size];
    newMonkey.physicsBody.friction = 0.0f;
    newMonkey.physicsBody.restitution = 1.0f;
    newMonkey.physicsBody.linearDamping = 0.0f;
    newMonkey.physicsBody.allowsRotation = YES;
    newMonkey.physicsBody.affectedByGravity = YES;
    
    [projectile removeFromParent];
    [monkey removeFromParent];
    self.monkeysDestroyed++;
    self.score = (self.monkeysDestroyed);
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", self.score]];
    if(self.monkeysDestroyed >= 30) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:.5];
        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
        [self.view presentScene:gameOverScene transition: reveal];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monkeyCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithmonkey:(SKSpriteNode *) secondBody.node];
    }
}
@end
