//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Richie Austerberry on 22/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

@interface LoginViewController () <UIWebViewDelegate>

-(void)updateButtons;

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *backButton;

@end

@implementation LoginViewController

NSString *const LoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";

-(NSString *) redirectURI {
return @"http://bloc.io";
}

-(void) loadView {
    UIWebView *webView = [[UIWebView alloc]init];
    webView.delegate = self;

    
    self.webView = webView;
    self.view = webView;
    
    self.backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
    
    self.navigationItem.leftBarButtonItem = self.backButton;
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if(url){
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

-(void) updateButtons {
    self.backButton.enabled = self.webView.canGoBack;

}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

-(void) dealloc{
    [self clearInstagramCookies];
    self.webView.delegate = nil;
}

-(void) clearInstagramCookies {
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if (domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = request.URL.absoluteString;
    
    if ([urlString hasPrefix:[self redirectURI]]) {
    
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginViewControllerDidGetAccessTokenNotification object:accessToken];
        return NO;
    
    }
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
