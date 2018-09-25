//
//  Part2ViewController.m
//  WKWebView
//
//  Created by shenyi on 2018/9/25.
//  Copyright © 2018年 shenyi. All rights reserved.
//

#import "Part2ViewController.h"
#import <WebKit/WebKit.h>

@interface Part2ViewController ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation Part2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - NavigationDelegate

#pragma mark - setter & getter
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    return _webView;
}

@end
