(function () {
    angular.module('trackto', [
        'ui.router',
        'toastr',
        'chart.js',
        'angular-steps',
        'ng-token-auth'
    ])
    // For authentication
    .config(function($authProvider) {
      $authProvider.configure({
        apiUrl:                  '/api',
        tokenValidationPath:     '/auth/validate_token',
        signOutUrl:              '/auth/sign_out',
        emailRegistrationPath:   '/auth',
        accountUpdatePath:       '/auth',
        accountDeletePath:       '/auth',
        confirmationSuccessUrl:  window.location.href,
        passwordResetPath:       '/auth/password',
        passwordUpdatePath:      '/auth/password',
        passwordResetSuccessUrl: window.location.href,
        emailSignInPath:         '/auth/sign_in',
        storage:                 'cookies',
        forceValidateToken:      false,
        proxyIf:                 function() { return false; },
        proxyUrl:                '/proxy',
        tokenFormat: {
          "access-token": "{{ token }}",
          "token-type":   "Bearer",
          "client":       "{{ clientId }}",
          "expiry":       "{{ expiry }}",
          "uid":          "{{ uid }}"
        },
        parseExpiry: function(headers) {
          // convert from UTC ruby (seconds) to UTC js (milliseconds)
          return (parseInt(headers['expiry']) * 1000) || null;
        },
        handleLoginResponse: function(response) {
          return response.data;
        },
        handleAccountUpdateResponse: function(response) {
          return response.data;
        },
        handleTokenValidationResponse: function(response) {
          return response.data;
        }
      });
    });
})();