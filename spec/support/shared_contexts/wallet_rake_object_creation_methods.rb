shared_context 'legacy_wallet_items' do
  let(:wallet) { create_wallet }
end

def create_legacy_wallet_item(type, options={})
  period_id = type == 'open' ? nil : 100

  wallet_attrs = {
    :wallet_id => wallet.id,
    :wallet_slot_id => 1,
    :wallet_slot_type_id => 1,
    :users_award_period_id => period_id,
    :offers_virtual_currency_id => nil,
    :type => nil
  }

  Plink::WalletItemRecord.new { |record| apply(record, wallet_attrs, options) }.tap(&:save!)
end

def create_legacy_wallet_slot
  ActiveRecord::Base.connection.execute(<<statement
  SET IDENTITY_INSERT [dbo].[walletSlots] ON;

  INSERT [dbo].[walletSlots] ([walletSlotID], [walletSlotTypeID], [lockedImage], [lockedText], [unLockedImage], [unLockedText], [displayOrder], [techNote], [mobileLockedText], [mobileUnLockedText]) VALUES (1, 1, N'assets/images/locked.png', N'To unlock this slot, join plink!', N'assets/images/plus.png', N'Select a restaurant from the left to start earning rewards from Plink!', 1, N'This slot is unlocked when a user joins plink. the locked fields should;
  never show', NULL, N'Select an offer');
  INSERT [dbo].[walletSlots] ([walletSlotID], [walletSlotTypeID], [lockedImage], [lockedText], [unLockedImage], [unLockedText], [displayOrder], [techNote], [mobileLockedText], [mobileUnLockedText]) VALUES (2, 2, N'assets/images/locked.png', N'Locked: to unlock this slot in your Plink Wallet for additional rewards,;
  complete your first Plink offer.', N'assets/images/plus.png', N'Select a restaurant from the left to start earning rewards from Plink!', 2, N'Unlocked when a user has 1 qualified transaction. Code is in the user;
  model on the offers.wall page', N'Complete an offer to unlock', N'Select an offer');
  INSERT [dbo].[walletSlots] ([walletSlotID], [walletSlotTypeID], [lockedImage], [lockedText], [unLockedImage], [unLockedText], [displayOrder], [techNote], [mobileLockedText], [mobileUnLockedText]) VALUES (3, 3, N'assets/images/locked.png', N'Locked: to unlock this slot, Refer a Friend to Plink. Earn;
  $vc_dollarAmount$ for every friend you refer.<br /><span class=" cursor;
  fontUnderline fontBlue referralDetails ">the details</span>', N'assets/images/plus.png', N'Select a restaurant from the left to start earning rewards from Plink!', 2, N'Unlocked when the users referral actually joins. Code is in the;
  userModel.successfulRegister', N'Refer a friend to unlock', N'Select an offer');
  INSERT [dbo].[walletSlots] ([walletSlotID], [walletSlotTypeID], [lockedImage], [lockedText], [unLockedImage], [unLockedText], [displayOrder], [techNote], [mobileLockedText], [mobileUnLockedText]) VALUES (4, 1, N'assets/images/locked.png', N'To unlock this slot, join plink!', N'assets/images/plus.png', N'Select a restaurant from the left to start earning rewards from Plink!', 1, N'This slot is unlocked when a user joins plink. the locked fields should;
  never show', NULL, N'Select an offer');
  INSERT [dbo].[walletSlots] ([walletSlotID], [walletSlotTypeID], [lockedImage], [lockedText], [unLockedImage], [unLockedText], [displayOrder], [techNote], [mobileLockedText], [mobileUnLockedText]) VALUES (5, 1, N'assets/images/locked.png', N'To unlock this slot, join plink!', N'assets/images/plus.png', N'Select a restaurant from the left to start earning rewards from Plink!', 1, N'This slot is unlocked when a user joins plink. the locked fields should;
  never show', NULL, N'Select an offer');

  SET IDENTITY_INSERT [dbo].[walletSlots] OFF;



  SET IDENTITY_INSERT [dbo].[walletSlotTypes] ON;

  INSERT [dbo].[walletSlotTypes] ([walletSlotTypeID], [walletSlotType]) VALUES (1, N'join');
  INSERT [dbo].[walletSlotTypes] ([walletSlotTypeID], [walletSlotType]) VALUES (2, N'transaction');
  INSERT [dbo].[walletSlotTypes] ([walletSlotTypeID], [walletSlotType]) VALUES (3, N'referral');

  SET IDENTITY_INSERT [dbo].[walletSlotTypes] OFF;
statement
)
end


def apply(object, defaults, overrides)
  options = defaults.merge(overrides)
  options.each do |method, value_or_proc|
    object.send("#{method}=", value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
  end
end
