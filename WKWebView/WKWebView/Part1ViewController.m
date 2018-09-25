//
//  Part1ViewController.m
//  WKWebView
//
//  Created by shenyi on 2018/9/20.
//  Copyright © 2018年 shenyi. All rights reserved.
//
/*
 这个类是给webView添加下拉刷新，前进后退刷新功能，网页加载进度条
 */
#import "Part1ViewController.h"
#import <WebKit/WebKit.h>
#import <MJRefresh.h>

@interface Part1ViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation Part1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.yzl1030.com/app.html"]];
    [self.webView loadRequest:request];
}

#pragma mark - UI
- (void)configUI {
    [self configSubViews];
    [self configRefreshHeader];
    [self configNavi];
    [self configProgressView];
}

- (void)configSubViews {
    self.webView.frame = self.view.frame;
    [self.view addSubview:self.webView];
}

- (void)configNavi {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithTitle:@"向前" style:UIBarButtonItemStylePlain target:self action:@selector(forwardAction)];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refreshAction)];
    self.navigationItem.rightBarButtonItems = @[backItem, forwardItem, refreshItem];
}

- (void)configRefreshHeader {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerAction)];
    self.webView.scrollView.mj_header = header;
}

- (void)configProgressView {
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    [self.view addSubview:self.progressView];
}

#pragma mark - Action
- (void)headerAction {
    [self refreshAction];
}

- (void)backAction {
    [self.webView goBack];
    NSLog(@"forwardList = %@", self.webView.backForwardList.forwardList);
    NSLog(@"backList = %@", self.webView.backForwardList.backList);
    NSLog(@"currentItem = %@", self.webView.backForwardList.currentItem);
}

- (void)forwardAction {
    [self.webView goForward];
}

- (void)refreshAction {
    [self.webView reload];
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.webView.estimatedProgress == 1.0) {
            self.progressView.hidden = YES;
        }
        else {
            self.progressView.hidden = NO;
            self.progressView.progress = self.webView.estimatedProgress;
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.webView.scrollView.mj_header endRefreshing];
}

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

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGFloat navigationBarAndStatusBarHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
        _progressView.frame = CGRectMake(0, navigationBarAndStatusBarHeight, self.view.bounds.size.width, 1);
        [_progressView setTrackTintColor:[UIColor redColor]];
        [_progressView setProgressTintColor:[UIColor greenColor]];
        _progressView.hidden = NO;
    }
    return _progressView;
}

@end
