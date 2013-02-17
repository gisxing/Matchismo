//
//  SetGameViewController.m
//  Matchismo
//
//  Created by Martin Mandl on 15.02.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCardDeck.h"
#import "SetCard.h"

@interface SetGameViewController ()

@end

@implementation SetGameViewController

@synthesize game = _game;

- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[[SetCardDeck alloc] init]];
        self.game.numberOfMatchingCards = 3;
        self.game.matchBonus = 2;
    }
    return _game;
}

- (NSAttributedString *)updateAttributedString:(NSAttributedString *)attributedString withAttributesOfCard:(SetCard *)card
{
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    
    NSRange range = [[mutableAttributedString string] rangeOfString:card.contents];
    if (range.location != NSNotFound) {
        NSString *symbol = @"?";
        if ([card.symbol isEqualToString:@"oval"]) symbol = @"●";
        if ([card.symbol isEqualToString:@"squiggle"]) symbol = @"▲";
        if ([card.symbol isEqualToString:@"diamond"]) symbol = @"■";
       
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        
        if ([card.color isEqualToString:@"red"])
            [attributes setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        if ([card.color isEqualToString:@"green"])
            [attributes setObject:[UIColor greenColor] forKey:NSForegroundColorAttributeName];
        if ([card.color isEqualToString:@"purple"])
            [attributes setObject:[UIColor purpleColor] forKey:NSForegroundColorAttributeName];

        if ([card.shading isEqualToString:@"solid"])
            [attributes setObject:@-5 forKey:NSStrokeWidthAttributeName];
        if ([card.shading isEqualToString:@"striped"])
            [attributes addEntriesFromDictionary:@{
                     NSStrokeWidthAttributeName : @-5,
                     NSStrokeColorAttributeName : attributes[NSForegroundColorAttributeName],
                     NSForegroundColorAttributeName : [attributes[NSForegroundColorAttributeName] colorWithAlphaComponent:0.1]
             }];
        if ([card.shading isEqualToString:@"open"])
            [attributes setObject:@5 forKey:NSStrokeWidthAttributeName];

        symbol = [symbol stringByPaddingToLength:card.number withString:symbol startingAtIndex:0];
        [mutableAttributedString replaceCharactersInRange:range
                                     withAttributedString:[[NSAttributedString alloc] initWithString:symbol
                                                                                          attributes:attributes]];
    }
    
    return mutableAttributedString;
}

- (void)updateUI
{
    NSAttributedString *lastFlip = [[NSAttributedString alloc] initWithString:self.game.descriptionOfLastFlip ? self.game.descriptionOfLastFlip : @""];
    
    for (UIButton *cardButton in self.cardButtons) {
        Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:card.contents];
        if ([card isKindOfClass:[SetCard class]]) {
            SetCard *setCard = (SetCard *)card;
            title = [self updateAttributedString:title withAttributesOfCard:setCard];
            lastFlip = [self updateAttributedString:lastFlip withAttributesOfCard:setCard];
       }
        [cardButton setAttributedTitle:title forState:UIControlStateNormal];
        cardButton.selected = card.isFaceUp;
        cardButton.enabled = !card.isUnplayable;
        cardButton.alpha = (card.isUnplayable ? 0.3 : 1.0);
        if (card.isFaceUp) {
            [cardButton setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
        } else {
            [cardButton setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    [super updateUI];
    
    self.resultOfLastFlipLabel.attributedText = lastFlip;
}


@end