//
//  UIFont+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 2/16/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "UIFont+MSKitAdditions.h"
#import "NSArray+MSKitAdditions.h"
#import "NSDictionary+MSKitAdditions.h"

static NSDictionary const * kFontAwesomeIconNameToUnicharIndex;

@implementation UIFont (MSKitAdditions)

+ (void)load
{
    kFontAwesomeIconNameToUnicharIndex =
        @{@"space"                 : @" ",      // SPACE
          @"uni00A0"               : @"\u00A0", // NO-BREAK SPACE
          @"dieresis"              : @"\u00A8", // DIAERESIS
          @"copyright"             : @"\u00A9", // COPYRIGHT SIGN
          @"registered"            : @"\u00AE", // REGISTERED SIGN
          @"acute"                 : @"\u00B4", // ACUTE ACCENT
          @"AE"                    : @"\u00C6", // LATIN CAPITAL LETTER AE
          @"uni2000"               : @"\u2000", // EN QUAD
          @"uni2001"               : @"\u2001", // EM QUAD
          @"uni2002"               : @"\u2002", // EN SPACE
          @"uni2003"               : @"\u2003", // EM SPACE
          @"uni2004"               : @"\u2004", // THREE-PER-EM SPACE
          @"uni2005"               : @"\u2005", // FOUR-PER-EM SPACE
          @"uni2006"               : @"\u2006", // SIX-PER-EM SPACE
          @"uni2007"               : @"\u2007", // FIGURE SPACE
          @"uni2008"               : @"\u2008", // PUNCTUATION SPACE
          @"uni2009"               : @"\u2009", // THIN SPACE
          @"uni200A"               : @"\u200A", // HAIR SPACE
          @"uni202F"               : @"\u202F", // NARROW NO-BREAK SPACE
          @"uni205F"               : @"\u205F", // MEDIUM MATHEMATICAL SPACE
          @"trademark"             : @"\u2122", // TRADE MARK SIGN
          @"infinity"              : @"\u221E", // INFINITY
          @"notequal"              : @"\u2260", // NOT EQUAL TO
          @"uniE000"               : @"\uE000",
          @"glass"                 : @"\uF000",
          @"music"                 : @"\uF001",
          @"search"                : @"\uF002",
          @"envelope"              : @"\uF003",
          @"heart"                 : @"\uF004",
          @"star"                  : @"\uF005",
          @"star-empty"            : @"\uF006",
          @"user"                  : @"\uF007",
          @"film"                  : @"\uF008",
          @"th-large"              : @"\uF009",
          @"th"                    : @"\uF00A",
          @"th-list"               : @"\uF00B",
          @"ok"                    : @"\uF00C",
          @"remove"                : @"\uF00D",
          @"zoom-in"               : @"\uF00E",
          @"zoom-out"              : @"\uF010",
          @"off"                   : @"\uF011",
          @"signal"                : @"\uF012",
          @"cog"                   : @"\uF013",
          @"trash"                 : @"\uF014",
          @"home"                  : @"\uF015",
          @"file"                  : @"\uF016",
          @"time"                  : @"\uF017",
          @"road"                  : @"\uF018",
          @"download-alt"          : @"\uF019",
          @"download"              : @"\uF01A",
          @"upload"                : @"\uF01B",
          @"inbox"                 : @"\uF01C",
          @"play-circle"           : @"\uF01D",
          @"repeat"                : @"\uF01E",
          @"refresh"               : @"\uF021",
          @"list-alt"              : @"\uF022",
          @"lock"                  : @"\uF023",
          @"flag"                  : @"\uF024",
          @"headphones"            : @"\uF025",
          @"volume-off"            : @"\uF026",
          @"volume-down"           : @"\uF027",
          @"volume-up"             : @"\uF028",
          @"qrcode"                : @"\uF029",
          @"barcode"               : @"\uF02A",
          @"tag"                   : @"\uF02B",
          @"tags"                  : @"\uF02C",
          @"book"                  : @"\uF02D",
          @"bookmark"              : @"\uF02E",
          @"print"                 : @"\uF02F",
          @"camera"                : @"\uF030",
          @"font"                  : @"\uF031",
          @"bold"                  : @"\uF032",
          @"italic"                : @"\uF033",
          @"text-height"           : @"\uF034",
          @"text-width"            : @"\uF035",
          @"align-left"            : @"\uF036",
          @"align-center"          : @"\uF037",
          @"align-right"           : @"\uF038",
          @"align-justify"         : @"\uF039",
          @"list"                  : @"\uF03A",
          @"indent-left"           : @"\uF03B",
          @"indent-right"          : @"\uF03C",
          @"facetime-video"        : @"\uF03D",
          @"picture"               : @"\uF03E",
          @"pencil"                : @"\uF040",
          @"map-marker"            : @"\uF041",
          @"adjust"                : @"\uF042",
          @"tint"                  : @"\uF043",
          @"edit"                  : @"\uF044",
          @"share"                 : @"\uF045",
          @"check"                 : @"\uF046",
          @"move"                  : @"\uF047",
          @"step-backward"         : @"\uF048",
          @"fast-backward"         : @"\uF049",
          @"backward"              : @"\uF04A",
          @"play"                  : @"\uF04B",
          @"pause"                 : @"\uF04C",
          @"stop"                  : @"\uF04D",
          @"forward"               : @"\uF04E",
          @"fast-forward"          : @"\uF050",
          @"step-forward"          : @"\uF051",
          @"eject"                 : @"\uF052",
          @"chevron-left"          : @"\uF053",
          @"chevron-right"         : @"\uF054",
          @"plus-sign"             : @"\uF055",
          @"minus-sign"            : @"\uF056",
          @"remove-sign"           : @"\uF057",
          @"ok-sign"               : @"\uF058",
          @"question-sign"         : @"\uF059",
          @"info-sign"             : @"\uF05A",
          @"screenshot"            : @"\uF05B",
          @"remove-circle"         : @"\uF05C",
          @"ok-circle"             : @"\uF05D",
          @"ban-circle"            : @"\uF05E",
          @"arrow-left"            : @"\uF060",
          @"arrow-right"           : @"\uF061",
          @"arrow-up"              : @"\uF062",
          @"arrow-down"            : @"\uF063",
          @"share-alt"             : @"\uF064",
          @"resize-full"           : @"\uF065",
          @"resize-small"          : @"\uF066",
          @"plus"                  : @"\uF067",
          @"minus"                 : @"\uF068",
          @"asterisk"              : @"\uF069",
          @"exclamation-sign"      : @"\uF06A",
          @"gift"                  : @"\uF06B",
          @"leaf"                  : @"\uF06C",
          @"fire"                  : @"\uF06D",
          @"eye-open"              : @"\uF06E",
          @"eye-close"             : @"\uF070",
          @"warning-sign"          : @"\uF071",
          @"plane"                 : @"\uF072",
          @"calendar"              : @"\uF073",
          @"random"                : @"\uF074",
          @"comment"               : @"\uF075",
          @"magnet"                : @"\uF076",
          @"chevron-up"            : @"\uF077",
          @"chevron-down"          : @"\uF078",
          @"retweet"               : @"\uF079",
          @"shopping-cart"         : @"\uF07A",
          @"folder-close"          : @"\uF07B",
          @"folder-open"           : @"\uF07C",
          @"resize-vertical"       : @"\uF07D",
          @"resize-horizontal"     : @"\uF07E",
          @"bar-chart"             : @"\uF080",
          @"twitter-sign"          : @"\uF081",
          @"facebook-sign"         : @"\uF082",
          @"camera-retro"          : @"\uF083",
          @"key"                   : @"\uF084",
          @"cogs"                  : @"\uF085",
          @"comments"              : @"\uF086",
          @"thumbs-up"             : @"\uF087",
          @"thumbs-down"           : @"\uF088",
          @"star-half"             : @"\uF089",
          @"heart-empty"           : @"\uF08A",
          @"signout"               : @"\uF08B",
          @"linkedin-sign"         : @"\uF08C",
          @"pushpin"               : @"\uF08D",
          @"external-link"         : @"\uF08E",
          @"signin"                : @"\uF090",
          @"trophy"                : @"\uF091",
          @"github-sign"           : @"\uF092",
          @"upload-alt"            : @"\uF093",
          @"lemon"                 : @"\uF094",
          @"phone"                 : @"\uF095",
          @"check-empty"           : @"\uF096",
          @"bookmark-empty"        : @"\uF097",
          @"phone-sign"            : @"\uF098",
          @"twitter"               : @"\uF099",
          @"facebook"              : @"\uF09A",
          @"github"                : @"\uF09B",
          @"unlock"                : @"\uF09C",
          @"credit-card"           : @"\uF09D",
          @"rss"                   : @"\uF09E",
          @"hdd"                   : @"\uF0A0",
          @"bullhorn"              : @"\uF0A1",
          @"bell"                  : @"\uF0A2",
          @"certificate"           : @"\uF0A3",
          @"hand-right"            : @"\uF0A4",
          @"hand-left"             : @"\uF0A5",
          @"hand-up"               : @"\uF0A6",
          @"hand-down"             : @"\uF0A7",
          @"circle-arrow-left"     : @"\uF0A8",
          @"circle-arrow-right"    : @"\uF0A9",
          @"circle-arrow-up"       : @"\uF0AA",
          @"circle-arrow-down"     : @"\uF0AB",
          @"globe"                 : @"\uF0AC",
          @"wrench"                : @"\uF0AD",
          @"tasks"                 : @"\uF0AE",
          @"filter"                : @"\uF0B0",
          @"briefcase"             : @"\uF0B1",
          @"fullscreen"            : @"\uF0B2",
          @"group"                 : @"\uF0C0",
          @"link"                  : @"\uF0C1",
          @"cloud"                 : @"\uF0C2",
          @"beaker"                : @"\uF0C3",
          @"cut"                   : @"\uF0C4",
          @"copy"                  : @"\uF0C5",
          @"paper-clip"            : @"\uF0C6",
          @"save"                  : @"\uF0C7",
          @"sign-blank"            : @"\uF0C8",
          @"reorder"               : @"\uF0C9",
          @"ul"                    : @"\uF0CA",
          @"ol"                    : @"\uF0CB",
          @"strikethrough"         : @"\uF0CC",
          @"underline"             : @"\uF0CD",
          @"table"                 : @"\uF0CE",
          @"magic"                 : @"\uF0D0",
          @"truck"                 : @"\uF0D1",
          @"pinterest"             : @"\uF0D2",
          @"pinterest-sign"        : @"\uF0D3",
          @"google-plus-sign"      : @"\uF0D4",
          @"google-plus"           : @"\uF0D5",
          @"money"                 : @"\uF0D6",
          @"caret-down"            : @"\uF0D7",
          @"caret-up"              : @"\uF0D8",
          @"caret-left"            : @"\uF0D9",
          @"caret-right"           : @"\uF0DA",
          @"columns"               : @"\uF0DB",
          @"sort"                  : @"\uF0DC",
          @"sort-down"             : @"\uF0DD",
          @"sort-up"               : @"\uF0DE",
          @"envelope-alt"          : @"\uF0E0",
          @"linkedin"              : @"\uF0E1",
          @"undo"                  : @"\uF0E2",
          @"legal"                 : @"\uF0E3",
          @"dashboard"             : @"\uF0E4",
          @"comment-alt"           : @"\uF0E5",
          @"comments-alt"          : @"\uF0E6",
          @"bolt"                  : @"\uF0E7",
          @"sitemap"               : @"\uF0E8",
          @"umbrella"              : @"\uF0E9",
          @"paste"                 : @"\uF0EA",
          @"light-bulb"            : @"\uF0EB",
          @"exchange"              : @"\uF0EC",
          @"cloud-download"        : @"\uF0ED",
          @"cloud-upload"          : @"\uF0EE",
          @"user-md"               : @"\uF0F0",
          @"stethoscope"           : @"\uF0F1",
          @"suitcase"              : @"\uF0F2",
          @"bell-alt"              : @"\uF0F3",
          @"coffee"                : @"\uF0F4",
          @"food"                  : @"\uF0F5",
          @"file-alt"              : @"\uF0F6",
          @"building"              : @"\uF0F7",
          @"hospital"              : @"\uF0F8",
          @"ambulance"             : @"\uF0F9",
          @"medkit"                : @"\uF0FA",
          @"fighter-jet"           : @"\uF0FB",
          @"beer"                  : @"\uF0FC",
          @"h-sign"                : @"\uF0FD",
          @"f0fe"                  : @"\uF0FE",
          @"double-angle-left"     : @"\uF100",
          @"double-angle-right"    : @"\uF101",
          @"double-angle-up"       : @"\uF102",
          @"double-angle-down"     : @"\uF103",
          @"angle-left"            : @"\uF104",
          @"angle-right"           : @"\uF105",
          @"angle-up"              : @"\uF106",
          @"angle-down"            : @"\uF107",
          @"desktop"               : @"\uF108",
          @"laptop"                : @"\uF109",
          @"tablet"                : @"\uF10A",
          @"mobile-phone"          : @"\uF10B",
          @"circle-blank"          : @"\uF10C",
          @"quote-left"            : @"\uF10D",
          @"quote-right"           : @"\uF10E",
          @"spinner"               : @"\uF110",
          @"circle"                : @"\uF111",
          @"reply"                 : @"\uF112",
          @"github-alt"            : @"\uF113",
          @"folder-close-alt"      : @"\uF114",
          @"folder-open-alt"       : @"\uF115",
          @"align-edges"           : @"\uF116",
          @"align-left-edges"      : @"\uF117",
          @"align-right-edges"     : @"\uF118",
          @"align-top-edges"       : @"\uF119",
          @"align-bottom-edges"    : @"\uF11A",
          @"align-center-x"        : @"\uF11B",
          @"align-center-y"        : @"\uF11C",
          @"align-size"            : @"\uF11D",
          @"align-vertical-size"   : @"\uF11E",
          @"align-horizontal-size" : @"\uF11F",
          @"align-size-exact"      : @"\uF120",
          @"bounds"                : @"\uF121"};

}

+ (UIFont*)fontAwesomeFontWithSize:(CGFloat)size
{
    return (  ([[UIFont familyNames] containsObject:@"FontAwesome"])
            ? [UIFont fontWithName:@"FontAwesome" size:size]
            : nil);
}

+ (NSSet *)fontAwesomeIconNames { return [[kFontAwesomeIconNameToUnicharIndex allKeys] set]; }

+ (NSSet *)fontAwesomeIconCharacters { return [[kFontAwesomeIconNameToUnicharIndex allValues] set]; }

+ (NSString *)fontAwesomeNameForIcon:(NSString *)icon
{
    __block NSString * name = nil;
    [kFontAwesomeIconNameToUnicharIndex enumerateKeysAndObjectsUsingBlock:
     ^(NSString *key, NSString *obj, BOOL *stop)
     {
         if ([icon isEqualToString:obj])
         {
             name = [key copy];
             *stop = YES;
         }
     }];
    return name;
}

+ (NSString *)fontAwesomeIconForName:(NSString *)name { return name ? kFontAwesomeIconNameToUnicharIndex[name] : nil; }

+ (NSAttributedString *)attributedFontAwesomeIconForName:(NSString *)name {
  NSString * iconForName = [self fontAwesomeIconForName:name];
  NSAttributedString * icon = nil;
  if (iconForName) {
    UIFont * font = [self fontAwesomeFontWithSize:[UIFont labelFontSize]];
    icon = [[NSAttributedString alloc] initWithString:iconForName attributes:@{NSFontAttributeName:font}];
  }
  return icon;
}

@end
