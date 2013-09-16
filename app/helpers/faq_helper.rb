module FaqHelper
  def faq_items
    {
      "What is Plink?" => "Plink is a rewards program that allows you to earn rewards for dining out and shopping offline. You select where you want to eat or shop, and Plink activates those offers on your credit or debit card. It's easy and safe!",
      "How long does it take to get points after I make a purchase?" => "It can be as fast as a day or as long as a week depending on your bank and where you made the purchase. If you have waited that long and still don't have the points, please contact us with your Plink-registered email address and purchase information including the date, where you went and how much you spent.",
      "Can my spouse and I both have a Plink account?" => "Absolutely! You and your spouse can both have a Plink account, as long as it's not a joint checking or credit card account. Your spouse will need to register a completely different account in order to earn rewards. Contact us if you have any questions about this, we'll be happy to clarify.",
      "Why can't I find my bank? Or I found my bank, but it says it's unsupported. Why?" => "While Plink works with most banks, there are still a few that we don't support. As soon as Plink is confident that we can successfully reward you for purchases made through a particular banking institution, we will add that bank to our supported list. We are constantly working to add banks to the Plink program, so your bank may become available at a future date. In the meantime, if you have a different credit card, you can register that.",
      "Why does Plink need my login (username and password) information for my credit or debit card provider?" => login_password_answer,
      "Why is Plink safe? How is my information stored?" => "Your bank information is stored in the safest way possible. Plink never receives or stores your log-in information. Intuit is the third party we use to store your log-in information and match transaction so we can give you rewards. Intuit also built Turbo Tax, #{mint_dot_com_link} and Quickbooks and are responsible for storing millions of federal tax returns that include not only sensitive income information, but also bank routing numbers and social security numbers. They have the highest level of security available and are 100% PCI Compliant.",
      "Can I add more than one card?" => "Currently you can only register one card for Plink rewards. This means you should register the card you use the most so that you don't miss out on any rewards.",
      "How do you know that I've made a purchase at a participating Plink location?" => "Simply pay with the credit or debit card you have registered with Plink, we will be notified of your purchase and award your Plink account. Plink is designed so you don't have to carry around an additional card, print out coupons, or use any type of code to get your rewards.",
      "Can I earn rewards for shopping and dining at participating partners multiple times?" => "Yup! If any of our offers are going to expire, we'll send you an email and post it on the site. In the meantime, go as often as you like!",
      "Why do I have to revalidate my account?" => (
      content_tag(:p, "Generally you get revalidation email if your bank has multiple security questions. Each time our automated process comes across a question it doesn't already have a stored answer for, you will have to revalidate.  So if you have 3 security questions, you will revalidate three times. Sometimes we'll get lucky and our process will get the same questions for a few days in a row, but eventually you will be asked to revalidate until we have all of the answers stored.") +
        content_tag(:p, "You will also need to revalidate any time you change your login credentials.")
      ),
      "I was missing points, but just realized I needed to revalidate my account. Will my points still be added?" => "As long as you revalidated your account within a week or so of receiving our revalidation email, you will receive your points. If you wait longer than, that it's possible that we may not get those transactions from your bank, just let us know as soon as you can so we can recover as many of your transactions as possible.",
      "How Does the Referral Program work?" => "A referral is considered successfully joined when he/she confirms his/her email address and links a card to their account. When you refer a friend, your first referral will unlock an additional slot in your wallet and you will receive 100 Plink points. For each friend that successfully joins, we'll give you 100 Plink. Spread the word.",
      "What will happen to my points if I need to return something I've purchased at a retail location?" => "Plink reserves the right to withhold any points for up to 90 days. If the points are awarded and the purchases are returned, those could be removed from your account and no rewards will be shipped.",
      "Why do I have to reverify my account multiple times?" => "Generally you get those if your bank has multiple security questions. You'll likely get a reverification email a few times until we have all of your security answers on file. You will also have to reverify if you change any of your login information for your bank.",
      "I saw a promotion for a specific brand that isn't in my list of Plink merchants. Can I participate?" => "Occasionally Plink runs test brands to different groups of Plink members. If you ever see or hear about a specific Plink partner that isn't in your list of participating merchants please contact us and we will happily add them to your Plink account.",
      "I redeemed my points for a gift card, how and when will I receive it?" => "Most gift cards are sent via email within 24 - 48 hours of being ordered. Gift cards are sent from our gift card provider, Tango Card, or directly from the gift card carrier. If you've waited long a long time and still have not received your gift card, please contact us and we'd be happy to resend it.",
      "Is there a limit to how many times I can get double or triple points during the promotional period?" => "There is a limit to the number of bonus points you can get during a promotion. During any promotional period (from when it starts to the expiration date), you may earn up to 2500 bonus points, unless otherwise stated in the promotion. Please read the promotion details for each promotion to find out more."
    }
  end

  private

  def login_password_answer
    paragraph_one = "We use your login credentials to establish a secure connection with your financial institution in order to automatically download your transaction information and match your purchases with offers you activated with Plink. Once a match is found, Plink automatically awards you.".html_safe
    paragraph_two = "Rest assured, all bank credentials are securely encrypted and no Plink employee has access to that information. Currently several reputable companies use this technology, including #{mint_dot_com_link} and #{paypal_link}.".html_safe

    content_tag(:p, paragraph_one) + content_tag(:p, paragraph_two)
  end

  def mint_dot_com_link
    link_to("Mint.com", "http://www.mint.com")
  end

  def paypal_link
    link_to("Paypal", "http://www.paypal.com")
  end
end
