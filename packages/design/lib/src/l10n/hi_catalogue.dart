/// The catalogue, a product, a package and a professional's profile.
///
/// Split from `hi_customer.dart` because this is the browsing half and it has
/// its own vocabulary: dimensions, finishes, price units, trade ratings. A
/// translator checking whether `per running ft` reads correctly should not have
/// to scroll past the agreement copy to find it.
///
/// **Two rules that outrank fluency here.**
///
/// Prices are always hedged, because `effectivePrice` is a starting figure that
/// moves with the city and with what somebody actually wants made. `शुरुआती
/// क़ीमत` keeps the hedge; a bare `क़ीमत` does not, and a customer who reads it
/// as *the* price will hold us to it.
///
/// And "request this professional" must never read as a booking. Assignment is
/// ops' decision; naming somebody is a preference they try to honour.
library;

const hiCatalogue = <String, String>{
  // ---- browsing ----
  'Catalogue': 'कैटलॉग',
  'What we make': 'हम क्या बनाते हैं',
  'Our work': 'हमारा काम',
  'Jobs already done': 'पूरे हो चुके काम',
  'Filter': 'छाँटें',
  'Clear all': 'सब हटाएँ',
  'Show results': 'नतीजे दिखाएँ',
  'Category': 'श्रेणी',
  'Within this trade': 'इसी काम के अंदर',
  'City': 'शहर',

  /// The city is not an ordinary filter — it changes every price on the
  /// screen behind it, and the label has to say so.
  'Prices follow the city': 'दाम शहर के हिसाब से बदलते हैं',
  'Featured': 'चुनिंदा',
  'Price: low to high': 'दाम: कम से ज़्यादा',
  'Price: high to low': 'दाम: ज़्यादा से कम',
  'Top rated': 'सबसे अच्छी रेटिंग',
  'Nothing matches': 'कुछ नहीं मिला',
  'Try a wider price, or clear a filter. Everything here can also be made to order — tell us what you need instead.':
      'दाम की सीमा बढ़ाइए, या कोई छँटनी हटाइए। यहाँ का सब कुछ ऑर्डर पर भी बन सकता है — बता दीजिए आपको क्या चाहिए।',

  // ---- a product ----
  ///
  /// "Starting at", never a bare price. The figure moves with the city and
  /// with what is actually being made.
  'Starting at': 'शुरुआती क़ीमत',
  'In {city}': '{city} में',
  'Prices vary by city. Choose one in the filter to see yours.':
      'दाम शहर के हिसाब से अलग होते हैं। अपना देखने के लिए छँटनी में शहर चुनिए।',
  'Made to your measurements': 'आपकी नाप के हिसाब से',
  'About this': 'इसके बारे में',
  'Detail': 'ब्यौरा',
  'Specification': 'ब्यौरेवार जानकारी',
  'As supplied': 'जैसा दिया जाएगा',
  'Usually about {n} day once work starts':
      'काम शुरू होने पर आम तौर पर {n} दिन',
  'Usually about {n} days once work starts':
      'काम शुरू होने पर आम तौर पर {n} दिन',
  'Get quotes for this': 'इसके लिए कोटेशन मँगाएँ',

  /// There is no cart, and the copy has to explain why rather than leaving
  /// somebody hunting for one. The platform sells nothing.
  'Nothing is bought here. We take this to three verified professionals and bring back their prices.':
      'यहाँ कुछ ख़रीदा नहीं जाता। हम यह तीन जाँचे हुए कारीगरों तक ले जाते हैं और उनके दाम आपके पास लाते हैं।',
  'Similar work': 'मिलता-जुलता काम',
  'Also in this trade': 'इसी काम में और',

  // ---- price units ----
  'per piece': 'प्रति नग',
  'per sq.ft': 'प्रति वर्ग फुट',
  'per running ft': 'प्रति रनिंग फ़ीट',
  'per kg': 'प्रति किलो',
  'per room': 'प्रति कमरा',
  'per project': 'प्रति प्रोजेक्ट',

  // ---- a professional ----
  ///
  /// Per trade is the whole point. A single average under a trade heading is
  /// the wrong number under the right label.
  'Rated by trade': 'काम के हिसाब से रेटिंग',
  'Not one average': 'एक औसत नहीं',
  'This trade': 'यह काम',
  '{n} job completed': '{n} काम पूरा',
  '{n} jobs completed': '{n} काम पूरे',
  'Where they work': 'ये कहाँ काम करते हैं',
  'Service areas': 'काम के इलाक़े',
  'Speaks {languages}': '{languages} बोलते हैं',
  'Their work': 'इनका काम',
  'Approved for the public profile': 'सार्वजनिक प्रोफ़ाइल के लिए मंज़ूर',
  'Reviews': 'रिव्यू',
  'From completed jobs': 'पूरे हुए कामों से',

  /// A preference, not a booking. A customer who reads this as a booking and
  /// then receives three other quotes has been misled by us.
  'Request this professional': 'इन्हीं कारीगर को माँगें',
  'We pass this on as a preference and try to honour it. You will still see quotes from others, so you can compare.':
      'हम यह आपकी पसंद के तौर पर आगे बताते हैं और उसे पूरा करने की कोशिश करते हैं। बाक़ी कारीगरों के कोटेशन भी आपको दिखेंगे, ताकि आप मिलाकर देख सकें।',

  // ---- packages ----
  ///
  /// A package is a bounded scope, and what it *excludes* is why a customer
  /// trusts one. The Hindi gives the exclusions the same weight as the
  /// inclusions, because an exclusion discovered halfway through a job is the
  /// complaint that costs a professional their rating.
  'Packages': 'पैकेज',
  'Fixed scope, fixed price': 'तय काम, तय दाम',
  'Fixed scope': 'तय काम',
  'A fixed scope at a fixed price. Everything a package leaves out is listed too, because that is the part people find out about halfway through.':
      'तय काम, तय दाम। पैकेज में जो शामिल नहीं है वह भी लिखा है, क्योंकि लोगों को उसी का पता आधे काम के बाद चलता है।',
  'No packages yet': 'अभी कोई पैकेज नहीं',
  'Tell us what you need instead and we will have it quoted from scratch.':
      'इसके बजाय बता दीजिए आपको क्या चाहिए, हम शुरू से कोटेशन बनवा देंगे।',
  'What it covers': 'इसमें क्या-क्या है',
  'Line by line': 'एक-एक करके',
  'Included': 'शामिल है',
  'In the price': 'दाम में',
  'Quoted separately': 'अलग से कोटेशन होगा',
  'About {n} day of work': 'क़रीब {n} दिन का काम',
  'About {n} days of work': 'क़रीब {n} दिन का काम',
  'Get quotes for this package': 'इस पैकेज के लिए कोटेशन मँगाएँ',
  'The package sets the scope. Professionals still quote against it, so you see real prices before deciding.':
      'पैकेज से काम का दायरा तय होता है। कारीगर फिर भी उसी पर कोटेशन देते हैं, ताकि तय करने से पहले आपको असली दाम दिखें।',

  // ---- search ----
  'Search everything': 'सब कुछ खोजें',
  'Clear': 'मिटाएँ',
  'Products': 'उत्पाद',
  '{n} match': '{n} नतीजा',
  '{n} matches': '{n} नतीजे',
  'Reading': 'पढ़ने के लिए',
  'Products, packages, professionals and guides — all at once. Two letters is enough to start.':
      'उत्पाद, पैकेज, कारीगर और गाइड — सब एक साथ। शुरू करने के लिए दो अक्षर काफ़ी हैं।',
  'Nothing found': 'कुछ नहीं मिला',
  'Nothing matches that. Tell us what you need in your own words instead — most of what we do is made to order anyway.':
      'इससे कुछ नहीं मिला। अपने शब्दों में बता दीजिए आपको क्या चाहिए — वैसे भी हमारा ज़्यादातर काम ऑर्डर पर ही बनता है।',

  // ---- our work ----
  'Nothing published yet': 'अभी कुछ प्रकाशित नहीं',
  'Work appears here once our team has approved it for a public profile.':
      'हमारी टीम की मंज़ूरी के बाद काम यहाँ दिखने लगता है।',
  'Jobs already finished, photographed on site. Every one was checked by our team before it appeared here.':
      'पूरे हो चुके काम, साइट पर ली गई तस्वीरों के साथ। यहाँ आने से पहले हर एक को हमारी टीम ने जाँचा है।',
  'Recommended': 'सुझाए गए',
  'Top-rated professionals': 'सबसे अच्छी रेटिंग वाले कारीगर',
  'Most experienced teams': 'सबसे अनुभवी टीमें',

  /// City and rating belong to the professional, not the piece of work, and
  /// the heading says whose rating it is.
  'Professional’s rating': 'कारीगर की रेटिंग',
  '{n} project': '{n} प्रोजेक्ट',
  '{n} projects': '{n} प्रोजेक्ट',
  'Nothing matches these filters yet. Try clearing one, or tell us what you need.':
      'इन फ़िल्टर से अभी कुछ नहीं मिला। कोई फ़िल्टर हटाइए, या हमें बताइए कि आपको क्या चाहिए।',

  // ---- the catalogue's price and rating filters ----
  ///
  /// Bands are drawn from the trade's own prices, so the figures change from
  /// trade to trade; only the frame around them is copy.
  'Any price': 'कोई भी दाम',
  'Under {price}': '{price} से कम',
  '{from} – {to}': '{from} से {to}',
  '{price} and above': '{price} और उससे ज़्यादा',
  'Minimum': 'कम से कम',
  'Maximum': 'ज़्यादा से ज़्यादा',
  'Customer rating': 'ग्राहकों की रेटिंग',
};
