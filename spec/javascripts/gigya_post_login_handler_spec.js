describe('GigyaPostLoginHandler', function () {

  var callbackData;

  beforeEach(function () {
    callbackData = {
      UID: "_guid_dQpfkMXjALrer1JlrFZjOf0apvTncgs4PMjKXn1JdgI=",
      UIDSignature: "2dMY2Fl0QPfaISspgf1gk3ZHPtQ=",
      eventName: "login",
      provider: "site",
      signatureTimestamp: "1371768069",
      source: "showScreenSet",
      user: {
        UID: "_guid_dQpfkMXjALrer1JlrFZjOf0apvTncgs4PMjKXn1JdgI=",
        UIDSig: "",
        UIDSignature: "",
        age: 0,
        birthDay: 0,
        birthMonth: 0,
        birthYear: 0,
        callId: "3e4dc2dae268408fa8d8ecc0f4886694",
        capabilities: Object,
        city: "",
        country: "",
        email: "hunter@example.com",
        errorCode: 0,
        firstName: "Matt",
        gender: "",
        identities: Object,
        isConnected: true,
        isLoggedIn: true,
        isSiteUID: false,
        isSiteUser: true,
        isTempUser: false,
        lastName: "",
        loginProvider: "twitter",
        loginProviderUID: "1096399711",
        nickname: "MattPlink",
        oldestDataAge: 7,
        oldestDataUpdatedTimestamp: 1371768061646,
        photoURL: "http://a0.twimg.com/sticky/default_profile_images/default_profile_1.png",
        profileURL: "http://twitter.com/MattPlink",
        providers: '',
        proxiedEmail: "",
        signatureTimestamp: "",
        state: "",
        statusCode: 200,
        statusReason: "OK",
        thumbnailURL: "http://a0.twimg.com/sticky/default_profile_images/default_profile_1_normal.png",
        timestamp: "",
        zip: ""
      }
    }
  });

  describe('#handleLogin', function () {
    it('redirects when the user is from twitter and contains an encoded URI', function () {
      spyOn(Plink, 'redirect');

      GigyaPostLoginHandler.handleLogin(callbackData);

      expect(Plink.redirect).toHaveBeenCalledWith("/handle_gigya_login?email=hunter%40example.com&UID=_guid_dQpfkMXjALrer1JlrFZjOf0apvTncgs4PMjKXn1JdgI%3D&firstName=Matt");
    });

    it('redirects does not redirect when the user is from facebook', function () {
      spyOn(Plink, 'redirect');

      callbackData.user.loginProvider = 'facebook';

      GigyaPostLoginHandler.handleLogin(callbackData);

      expect(Plink.redirect).not.toHaveBeenCalled();
    });
  });
});

