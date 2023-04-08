import 'package:tokshop/utils/configs.dart';

var rooms = "$baseUrl/rooms";
var tokenPath = "$rooms/agora/rooom/generatetoken";
var rtmtoken = "$rooms/agora/rooom/rtmtoken";
var activetokshows = "$rooms/activetokshows/";
var allEvents = "$rooms/events";
var myEvents = "$rooms/myevents";
var roomById = "$rooms/rooms/";
var endedRoomById = "$rooms/ended/";
var record = "$rooms/record/";
var stoprecording = "$rooms/stoprecording/";
var eventById = "$rooms/event/";
var removeRoomProduct = "$rooms/rooms/product/";
var removeproductoroom = "$rooms/remove/featured/";
var updateroomurl = "$rooms/rooms/";
var removeFromCurrentRoom = "$rooms/removecurrentroom/";
var roomNotication = "$rooms/rooms/roomnotifications/";
var createRoom = "$rooms/";
var deleteRoom = "$rooms/rooms/";
var createEventE = "$rooms/newevent/";
var addUserToRoom = "$rooms/user/add/";
var removeUserFromRoomUrl = "$rooms/user/remove/";
var removeSpeaker = "$rooms/speaker/remove/";
var removeInvitedSpeaker = "$rooms/invitedSpeaker/remove/";
var removeHost = "$rooms/host/remove/";
var removeUserFromRaisedHands = "$rooms/raisedhans/remove/";

var product = "$baseUrl/products/";
var products = "$product/products/";

var favorite = "$baseUrl/favorite/";
var shop = "$baseUrl/shop/";
var import = "$baseUrl/import";
var importsp = "$baseUrl/import/shopify";
var updateproductimages = "${product}images/";
var singleproduct = "${product}product/";
var productreviews = "$baseUrl/products/review/";
var authenticatation = "$baseUrl/authenticate";
var settings = "$baseUrl/admin/app/settings";
var userExists = "$authenticatation/usercheck";
var authenticationsocial = "$authenticatation/social/mobileapp";
var address = "$baseUrl/address/";
var addressForUser = "${address}all/";
var transactions = "$baseUrl/transactions";
var notifications = "$baseUrl/notifications";
var channels = "$baseUrl/channels";

var flutterwave = "$baseUrl/flutterwave";
var flutterwaveBanks = "$flutterwave/banks/";

var passwordResetEmail = "$baseUrl/sendResetPasswordEmail";
var resetPassword = "$baseUrl/resetPassword";

var postChannel = "$channels/";
var userChannel = "$channels/member/";
var updateChannelById = "$channels/";
var addRoom = "$channels/rooms/add/";
var getChannelById = "$channels/";
var subscribeChannelUrl = "$channels/subscribe/";
var unsubscribeChannelUrl = "$channels/unsubscribe/";
var removeChannel = "$channels/";
var searchchannel = "$channels/search/";

//recording endpoints
var recordings = "$baseUrl/recording";
var userRecordings = "$recordings/user/";
var recordingById = "$recordings/id/";

var singleproductqtycheck = "${singleproduct}product/qtycheck/";
var limit = "15";

var updateshop = "${shop}shop/";
var followshop = "${shop}shop/follow/";
var unfollowshop = "${shop}shop/unfollow/";
var allShops = shop;
var popularshops = "${shop}/allshops/paginated";
var updateproduct = "${product}products/";
var allproductspaginated = "${product}paginated/allproducts";
var interestproducts = "${product}/interest/interest/products/";
var channelproducts = "${product}/channel/products/";

var user = "$baseUrl/users";
var userreviews = "$user/review/";
var paymentmethods = "$user/paymentmethod/";
var payoutmethods = "$user/payoutmethod/";
var userById = "$user/";
var usersummary = "$user/profile/summary/";
var userByAgoraId = "$user/agora/";
var checkcanreview = "$user/canreview/";
var userSendGift = "$user/sendgift";
var userFollowers = "$user/followers/";
var followersfollowing = "$user/followersfollowing/";
var userFollowing = "$user/following/";
var followUser = "$user/follow/";
var unFollowUser = "$user/unfollow/";
var editUser = "$user/";
var block = "$user/block/";
var unblock = "$user/unblock/";
var updateWallet = "$user/updateWallet/";
var upgradeUser = "$user/upgrade/";
var allUsers = "$user/allusers/";
var searchUsersByFirstName = "$user/search/";
var searchUsersByUserName = "$user/username/";
var followersfollowingsearch = "$user/followersfollowing/search/";
//use interests
var updateinterests = "$user/updateinterests";

var userProducts = "${product}get/all/";

var activities = "$baseUrl/activities";
var userActivities = "$activities/to/";
var addActivity = "$activities/";

var userTransactions = "$transactions/";
var userTransactionsPaginated = "$transactions/paginated/";
var updateTransactions = "$transactions/";

var orders = "$baseUrl/orders";
var oneOrder = "$orders/orders/";
var userOrders = "$orders/";
var allorders = "$orders/all/orders/";
var updateOrders = "$orders/orders/";
var cancelOrders = "$orders/cancelorder/";
var finishOrders = "$orders/finishorder/";

var stripeBase = "https://api.stripe.com/v1";
var connectStripeBase = "$baseUrl/stripe/connect/";
var createIntentStripeUrl = "$baseUrl/stripe/createIntent/";

var stripeAccounts = "$baseUrl/stripe/accounts";
var stripeAccountsDelete = "$baseUrl/stripe/accounts/delete";
var stripePayout = "$baseUrl/stripe/payouts";
var stripeBalance = "$baseUrl/stripe/balance";

var auction = "$baseUrl/auction/";
var auctionbid = "$baseUrl/auction/bid";
