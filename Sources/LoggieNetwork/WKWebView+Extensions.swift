//
//  WKWebView+Extensions.swift
//  Loggie
//
//  Created by Kangwook Lee on 6/12/25.
//

import WebKit
import LoggieNetwork

public extension WKWebView {
    func enableLoggieWebLogging() {
        let js = """
        (function() {
          // --- fetch wrapping
          const _fetch = window.fetch;
          window.fetch = async function(input, init = {}) {
            const url    = typeof input === 'string' ? input : input.url;
            const method = init.method || 'GET';
            // request body
            let reqBody = null;
            try {
              if (init.body instanceof Blob) {
                reqBody = '[Blob]';
              } else if (init.body instanceof FormData) {
                reqBody = JSON.stringify(Object.fromEntries(init.body.entries()));
              } else {
                reqBody = init.body;
              }
            } catch(_) {}

            const start = performance.now();
            
            const response = await _fetch.apply(this, arguments);
            const duration = performance.now() - start;
            
            let resBody = null;
            try {
              resBody = await response.clone().text();
            } catch(_) {}
            
            const status = response.status;

            window.webkit.messageHandlers.loggie.postMessage({
              url, method, duration, status,
              requestBody: reqBody, responseBody: resBody
            });

            return response;
          };

          // --- XMLHttpRequest wrapping
          const _open = XMLHttpRequest.prototype.open;
          const _send = XMLHttpRequest.prototype.send;
          XMLHttpRequest.prototype.open = function(method, url) {
            this.__loggie = { method, url };
            return _open.apply(this, arguments);
          };
          XMLHttpRequest.prototype.send = function(body) {
            const info = this.__loggie || {};
            const start = performance.now();
            this.addEventListener('loadend', function() {
              const duration = performance.now() - start;
              const status = this.status;
              let resBody = null;
              try { resBody = this.responseText; } catch(_) {}
              window.webkit.messageHandlers.loggie.postMessage({
                url: info.url, method: info.method,
                duration, status,
                requestBody: body, responseBody: resBody
              });
            });
            return _send.apply(this, arguments);
          };
        })();
        """

        let userScript = WKUserScript(
            source: js,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(userScript)
        configuration.userContentController.add(
            LoggieWebViewMessageHandler.shared,
            name: "loggie"
        )
    }
}
