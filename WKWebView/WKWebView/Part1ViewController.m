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
    //rightItems
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithTitle:@"向前" style:UIBarButtonItemStylePlain target:self action:@selector(forwardAction)];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refreshAction)];
    
    self.navigationItem.rightBarButtonItems = @[backItem, forwardItem, refreshItem];
    
    //leftItems
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backNaviItemAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItems = @[backButtonItem];
}

- (void)configRefreshHeader {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerAction)];
    self.webView.scrollView.mj_header = header;
}

- (void)configProgressView {
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    [self.view addSubview:self.progressView];
}

- (void)addCloseButtonItem {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeNaviItemAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
    [array addObject:closeButtonItem];
    self.navigationItem.leftBarButtonItems = array;
}

#pragma mark - Action
- (void)headerAction {
    [self refreshAction];
}

- (void)backAction {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
    NSLog(@"forwardList = %@", self.webView.backForwardList.forwardList);
    NSLog(@"backList = %@", self.webView.backForwardList.backList);
    NSLog(@"currentItem = %@", self.webView.backForwardList.currentItem);
}

- (void)forwardAction {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)refreshAction {
    //如果点击了好几个层级，刷新webView承载的原始页面
    if ([self.webView canGoBack]) {
        WKBackForwardListItem *item = self.webView.backForwardList.backList.firstObject;
        NSURLRequest *request = [NSURLRequest requestWithURL:item.initialURL];
        [self.webView loadRequest:request];
    } else {
        //刷新当前页面
        [self.webView reload];
    }
}

- (void)backNaviItemAction {
    //能后退就后退，不能后退就pop
    if ([self.webView canGoBack]) {
        [self backAction];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeNaviItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && [object isKindOfClass:[WKWebView class]]) {
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
    
    if ([self.webView canGoBack] && (self.navigationItem.leftBarButtonItems.count <= 1)) {
        [self addCloseButtonItem];
    }
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
