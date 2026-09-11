// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/account_closure.dart';
import '../models/app_version.dart';
import '../models/auth_session.dart';
import '../models/banner.dart';
import '../models/blog_category.dart';
import '../models/blog_post_view.dart';
import '../models/blog_tag.dart';
import '../models/catalogue_count.dart';
import '../models/city.dart';
import '../models/complete_google_sign_up_body.dart';
import '../models/confirm_mobile_verification_body.dart';
import '../models/create_upload_ticket_body.dart';
import '../models/delete_account_body.dart';
import '../models/domain.dart';
import '../models/get_posts_response.dart';
import '../models/get_products_response.dart';
import '../models/get_professionals_response.dart';
import '../models/google_sign_in_body.dart';
import '../models/google_sign_in_result.dart';
import '../models/ok.dart';
import '../models/otp_challenge.dart';
import '../models/package_view.dart';
import '../models/platform_stats.dart';
import '../models/portfolio_item.dart';
import '../models/product_category.dart';
import '../models/product_view.dart';
import '../models/professional_profile.dart';
import '../models/register_device_body.dart';
import '../models/request_otp_body.dart';
import '../models/search_results.dart';
import '../models/search_suggestion.dart';
import '../models/session_user.dart';
import '../models/sort.dart';
import '../models/sort2.dart';
import '../models/staff_login_body.dart';
import '../models/testimonial.dart';
import '../models/update_profile_body.dart';
import '../models/upload_ticket.dart';
import '../models/verify_otp_body.dart';

part 'public_client.g.dart';

@RestApi()
abstract class PublicClient {
  factory PublicClient(Dio dio, {String? baseUrl}) = _PublicClient;

  /// Send a six-digit code to a mobile number, on WhatsApp or by SMS.
  ///
  /// Send a six-digit code to a mobile number, on WhatsApp or by SMS No session required.
  @POST('/auth/otp/request')
  Future<OtpChallenge> requestOtp({@Body() required RequestOtpBody body});

  /// Sign in with a Google ID token, or be told an account still has to be made.
  ///
  /// Sign in with a Google ID token, or be told an account still has to be made No session required.
  @POST('/auth/google')
  Future<GoogleSignInResult> googleSignIn({
    @Body() required GoogleSignInBody body,
  });

  /// Create the account behind a verified Google identity and sign in.
  ///
  /// Create the account behind a verified Google identity and sign in No session required.
  @POST('/auth/google/complete')
  Future<AuthSession> completeGoogleSignUp({
    @Body() required CompleteGoogleSignUpBody body,
  });

  /// Exchange a code for a session cookie, creating the account if new.
  ///
  /// Exchange a code for a session cookie, creating the account if new No session required.
  @POST('/auth/otp/verify')
  Future<AuthSession> verifyOtp({@Body() required VerifyOtpBody body});

  /// Password and TOTP sign-in for ops and admin.
  ///
  /// Password and TOTP sign-in for ops and admin No session required.
  @POST('/auth/staff/login')
  Future<AuthSession> staffLogin({@Body() required StaffLoginBody body});

  /// Revoke the current session.
  ///
  /// Revoke the current session No session required.
  @POST('/auth/logout')
  Future<Ok> logout();

  /// The signed-in actor, or 401.
  ///
  /// The signed-in actor, or 401 No session required.
  @GET('/me')
  Future<SessionUser> me();

  /// Set or change the name and city on the signed-in account.
  ///
  /// Set or change the name and city on the signed-in account No session required.
  @PATCH('/me/profile')
  Future<SessionUser> updateProfile({@Body() required UpdateProfileBody body});

  /// Send a code to a number the signed-in person wants to add.
  ///
  /// Send a code to a number the signed-in person wants to add No session required.
  @POST('/me/mobile/request')
  Future<OtpChallenge> requestMobileVerification({
    @Body() required RequestOtpBody body,
  });

  /// Prove that number and attach it to the signed-in account.
  ///
  /// Prove that number and attach it to the signed-in account No session required.
  @POST('/me/mobile/confirm')
  Future<SessionUser> confirmMobileVerification({
    @Body() required ConfirmMobileVerificationBody body,
  });

  /// Register this handset for push, against the current session.
  ///
  /// Register this handset for push, against the current session No session required.
  @POST('/me/devices')
  Future<Ok> registerDevice({@Body() required RegisterDeviceBody body});

  /// Stop pushing to this handset.
  ///
  /// Stop pushing to this handset No session required.
  @DELETE('/me/devices/{token}')
  Future<Ok> forgetDevice({@Path('token') required String token});

  /// Close the account and revoke every session.
  ///
  /// Close the account and revoke every session No session required.
  @POST('/me/account/delete')
  Future<AccountClosure> deleteAccount({
    @Body() required DeleteAccountBody body,
  });

  /// Minimum supported build, and where to get a newer one.
  ///
  /// Minimum supported build, and where to get a newer one No session required.
  @GET('/app/version')
  Future<AppVersion> appVersion();

  /// listDomains.
  ///
  /// No session required.
  @GET('/domains')
  Future<List<Domain>> listDomains();

  /// getDomain.
  ///
  /// No session required.
  @GET('/domains/{slug}')
  Future<Domain> getDomain({@Path('slug') required String slug});

  /// listCities.
  ///
  /// No session required.
  @GET('/cities')
  Future<List<City>> listCities();

  /// listProducts.
  ///
  /// No session required.
  @GET('/products')
  Future<GetProductsResponse> listProducts({
    @Query('cursor') String? cursor,
    @Query('domain') String? domain,
    @Query('category') String? category,
    @Query('search') String? search,
    @Query('tags') String? tags,
    @Query('city') String? city,
    @Query('minPrice') int? minPrice,
    @Query('maxPrice') int? maxPrice,
    @Query('minRating') num? minRating,
    @Query('limit') int? limit = 24,
    @Query('sort') Sort? sort = Sort.featured,
  });

  /// getProduct.
  ///
  /// No session required.
  @GET('/products/{slug}')
  Future<ProductView> getProduct({
    @Path('slug') required String slug,
    @Query('city') String? city,
  });

  /// listRelatedProducts.
  ///
  /// No session required.
  @GET('/products/{id}/related')
  Future<List<ProductView>> listRelatedProducts({
    @Path('id') required String id,
    @Query('limit') int? limit = 4,
    @Query('city') String? city,
  });

  /// listCategories.
  ///
  /// No session required.
  @GET('/categories')
  Future<List<ProductCategory>> listCategories({
    @Query('domain') String? domain,
  });

  /// listPackages.
  ///
  /// No session required.
  @GET('/packages')
  Future<List<PackageView>> listPackages({
    @Query('domain') String? domain,
    @Query('featured') bool? featured,
    @Query('limit') int? limit,
  });

  /// getPackage.
  ///
  /// No session required.
  @GET('/packages/{slug}')
  Future<PackageView> getPackage({@Path('slug') required String slug});

  /// catalogueCounts.
  ///
  /// No session required.
  @GET('/catalogue/counts')
  Future<List<CatalogueCount>> catalogueCounts();

  /// listProfessionals.
  ///
  /// No session required.
  @GET('/professionals')
  Future<GetProfessionalsResponse> listProfessionals({
    @Query('cursor') String? cursor,
    @Query('domain') String? domain,
    @Query('city') String? city,
    @Query('search') String? search,
    @Query('verifiedOnly') bool? verifiedOnly,
    @Query('minRating') num? minRating,
    @Query('minExperience') int? minExperience,
    @Query('limit') int? limit = 24,
    @Query('sort') Sort2? sort = Sort2.rating,
  });

  /// getProfessional.
  ///
  /// No session required.
  @GET('/professionals/{id}')
  Future<ProfessionalProfile> getProfessional({@Path('id') required String id});

  /// listPortfolio.
  ///
  /// No session required.
  @GET('/portfolio')
  Future<List<PortfolioItem>> listPortfolio({
    @Query('domain') String? domain,
    @Query('limit') int? limit,
  });

  /// platformStats.
  ///
  /// No session required.
  @GET('/stats')
  Future<PlatformStats> platformStats();

  /// listPosts.
  ///
  /// No session required.
  @GET('/posts')
  Future<GetPostsResponse> listPosts({
    @Query('cursor') String? cursor,
    @Query('category') String? category,
    @Query('tag') String? tag,
    @Query('domain') String? domain,
    @Query('search') String? search,
    @Query('limit') int? limit = 24,
  });

  /// getPost.
  ///
  /// No session required.
  @GET('/posts/{slug}')
  Future<BlogPostView> getPost({@Path('slug') required String slug});

  /// listRelatedPosts.
  ///
  /// No session required.
  @GET('/posts/{id}/related')
  Future<List<BlogPostView>> listRelatedPosts({
    @Path('id') required String id,
    @Query('limit') int? limit = 3,
  });

  /// listPostCategories.
  ///
  /// No session required.
  @GET('/posts/categories')
  Future<List<BlogCategory>> listPostCategories();

  /// listPostTags.
  ///
  /// No session required.
  @GET('/posts/tags')
  Future<List<BlogTag>> listPostTags();

  /// listBanners.
  ///
  /// No session required.
  @GET('/banners')
  Future<List<Banner>> listBanners();

  /// listTestimonials.
  ///
  /// No session required.
  @GET('/testimonials')
  Future<List<Testimonial>> listTestimonials();

  /// search.
  ///
  /// No session required.
  @GET('/search')
  Future<SearchResults> search({
    @Query('q') required String q,
    @Query('city') String? city,
  });

  /// searchSuggest.
  ///
  /// No session required.
  @GET('/search/suggest')
  Future<List<SearchSuggestion>> searchSuggest({@Query('q') required String q});

  /// A short-lived URL to PUT one file straight at storage.
  ///
  /// A short-lived URL to PUT one file straight at storage No session required.
  @POST('/uploads/tickets')
  Future<UploadTicket> createUploadTicket({
    @Body() required CreateUploadTicketBody body,
  });
}
