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

  // ---- our work ----
  'Nothing published yet': 'अभी कुछ प्रकाशित नहीं',
  'Work appears here once our team has approved it for a public profile.':
      'हमारी टीम की मंज़ूरी के बाद काम यहाँ दिखने लगता है।',
  'Jobs already finished, photographed on site. Every one was checked by our team before it appeared here.':
      'पूरे हो चुके काम, साइट पर ली गई तस्वीरों के साथ। यहाँ आने से पहले हर एक को हमारी टीम ने जाँचा है।',
};
