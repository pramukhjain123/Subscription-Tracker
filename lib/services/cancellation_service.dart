import 'dart:collection';

class CancellationService {
  static final Map<String, String> _urlByKey = UnmodifiableMapView({
    // Streaming & Entertainment
    'netflix': 'https://www.netflix.com/cancelplan',
    'amazon prime video': 'https://www.amazon.in/gp/video/settings',
    'disney+ hotstar': 'https://help.hotstar.com/in/en/support/solutions/articles/16000104216-how-do-i-cancel-my-subscription-',
    'hotstar': 'https://help.hotstar.com/in/en/support/solutions/articles/16000104216-how-do-i-cancel-my-subscription-',
    'jiohotstar': 'https://help.hotstar.com/in/en/support/solutions/articles/16000104216-how-do-i-cancel-my-subscription-',
    'sonyliv': 'https://www.sonyliv.com/subscription',
    'zee5': 'https://www.zee5.com/myprofile/subscription',
    'spotify': 'https://www.spotify.com/account/subscription/',
    'gaana': 'https://gaana.com/faq#subscriptions',
    'jiosaavn': 'https://support.jiosaavn.com/hc/en-us/articles/360033671572-How-do-I-cancel-my-JioSaavn-Pro-subscription',
    'apple music': 'https://support.apple.com/en-in/HT212207',
    'youtube premium': 'https://www.youtube.com/premium/manage',
    'audible': 'https://www.audible.in/account/cancellation',
    'kindle unlimited': 'https://www.amazon.in/kindle-dbs/ku/ku-central',

    // Subscription Boxes (many cancel via account or support)
    'birchbox': 'https://support.birchbox.com/hc/en-us/articles/360030568072-How-do-I-cancel-my-subscription',
    'fab bag': 'https://www.fabbag.com/pages/faq',
    'the man company': 'https://www.themancompany.com/pages/contact-us',
    'letshave': 'https://www.letsshave.com/pages/faq',
    'ka-gazi': 'https://kagazi.in/pages/contact-us',
    'the whole truth': 'https://www.thewholettruthfoods.com/pages/faq',
    'blue tokai coffee roasters': 'https://bluetokaicoffee.com/pages/subscription-faq',
    'tea box': 'https://in.teabox.com/pages/subscription-faqs',
    'snackible': 'https://snackible.com/pages/contact-us',
    'dogsee chew': 'https://www.dogseechew.com/pages/contact-us',

    // Software & Productivity (SaaS)
    'microsoft 365': 'https://account.microsoft.com/services',
    'google workspace': 'https://support.google.com/a/answer/1257646?hl=en',
    'adobe creative cloud': 'https://helpx.adobe.com/manage-account/using/cancel-subscription.html',
    'tally': 'https://tallysolutions.com/support/',
    'zoho books': 'https://www.zoho.com/books/kb/subscription/cancel-subscription.html',
    'quickbooks': 'https://quickbooks.intuit.com/learn-support/en-in/help-article/manage-billing-subscription/cancel-quickbooks-online-subscription/IN_en_IN-01',
    'canva pro': 'https://www.canva.com/help/article/cancel-subscription/',
    'notion': 'https://www.notion.so/help/canceling-a-subscription',
    'slack': 'https://slack.com/help/articles/218915077-Manage-your-Slack-plan',
    'zoom': 'https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0064507',
    'dropbox': 'https://help.dropbox.com/account-billing/change-plan/cancel-paid-subscription',
    'evernote': 'https://help.evernote.com/hc/en-us/articles/209005247-Cancel-a-subscription',

    // Memberships & Services
    'amazon prime': 'https://www.amazon.in/gp/video/settings',
    'flipkart plus': 'https://www.flipkart.com/pages/plus',
    'zomato gold': 'https://www.zomato.com/blog/gold-terms',
    'swiggy one': 'https://www.swiggy.com/my-account/swiggy-one',
    'times prime': 'https://www.timesprime.com/faqs',
    'cult.fit (cultpass)': 'https://www.cult.fit/faq',
    'urban company (uc plus)': 'https://www.urbancompany.com/plus',
    'bigbasket (bbstar)': 'https://www.bigbasket.com/bbstar/',

    // Financial Services (info pages only; cancel via provider)
    'lic (life insurance corporation of india)': 'https://licindia.in/web/guest/contact-us',
    'hdfc life': 'https://www.hdfclife.com/customer-service/service-requests/policy-cancellation',
    'icici prudential life insurance': 'https://www.iciciprulife.com/support/policy-servicing/cancellation.html',
    'bajaj finserv': 'https://www.bajajfinserv.in/help-and-support',
    'hdfc bank (for loans, credit cards)': 'https://www.hdfcbank.com/personal/resources/customer-centre',
    'icici bank (for loans, credit cards)': 'https://help.icicibank.com/',
    'state bank of india (for loans, credit cards)': 'https://sbi.co.in/web/customer-support',
    'axis bank (for loans, credit cards)': 'https://www.axisbank.com/contact-us',
    'zerodha (for sips)': 'https://support.zerodha.com/category/console/portfolio/sips/articles/cancel-sip',
    'upstox (for sips)': 'https://help.upstox.com/support/solutions/articles/26100044083-how-to-cancel-sip-',
    'groww (for sips)': 'https://groww.in/help/articles/how-to-cancel-sip',
    'paytm (for utility bills, sips)': 'https://paytm.com/helpinghand',
    'phonepe (for utility bills, sips)': 'https://www.phonepe.com/en/support/',
    'google pay (for utility bills, sips)': 'https://support.google.com/pay/india/answer/9039712?hl=en',

    // Utilities & Bills
    'airtel (postpaid, broadband)': 'https://www.airtel.in/help/complaints',
    'jio (postpaid, fiber)': 'https://www.jio.com/help',
    'vodafone idea (vi) (postpaid)': 'https://www.myvi.in/help-support',
    'tata power': 'https://www.tatapower.com/contactus.aspx',
    'adani electricity': 'https://www.adanielectricity.com/customerzone/faqs',
    'bses rajdhani power limited': 'https://www.bsesdelhi.com/web/brpl',
    'indraprastha gas limited (igl)': 'https://www.iglonline.net/english/customer-support',
    'mahanagar gas limited (mgl)': 'https://www.mahanagargas.com/english/contact-us',
    'delhi jal board': 'https://djb.gov.in/',
    'brihanmumbai municipal corporation (for water tax)': 'https://portal.mcgm.gov.in/irj/portal/anonymous',
    'national payments corporation of india (for nach mandates)': 'https://www.npci.org.in/',
  });

  static Uri? getCancellationUrl(String serviceName) {
    final String key = serviceName.trim().toLowerCase();
    for (final entry in _urlByKey.entries) {
      if (key.contains(entry.key)) {
        return Uri.parse(entry.value);
      }
    }
    return null;
  }
}


