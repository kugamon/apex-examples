@isTest
public class KugamonTests {

    @isTest static void test1() {
        DataSetup();

        // Switch to test context
        Test.startTest();

        Assert.isFalse(OrderProductLines.isEmpty(), 'Must have at least one Order Product Line.');

        // Switch back to runtime context
        Test.stopTest();

    }

/*****************************************************************************************************************************************
                                                Setup test data
 *****************************************************************************************************************************************/

    public static String CurrencyIsoCodeField {
        get {
            return kugo2p.Currencies.isMultiCurrencyEnabled ? 'CurrencyIsoCode, ' : '';
        }
    }
    
    public static kugo2p__SalesQuote__c getSalesQuote(Id sqId) {
        return Database.query('select Id, Name, ' + CurrencyIsoCodeField + 'kugo2p__Account__c, kugo2p__Account__r.Name,' + 
                                       'kugo2p__Opportunity__c, kugo2p__PriceBook2Id__c, kugo2p__PriceBookName__c, kugo2p__DiscountPercent__c, kugo2p__DateRequired__c, kugo2p__IsPrimary__c' + 
                                ' from kugo2p__SalesQuote__c where Id = :sqId');
    }
 
    public static kugo2p__SalesOrder__c getSalesOrder(Id soId) {        
        return Database.query('select Id, Name, ' + CurrencyIsoCodeField + 'kugo2p__Account__c, kugo2p__Account__r.Name,' + 
                                       'kugo2p__Opportunity__c, kugo2p__OrderDate__c, kugo2p__PriceBook2Id__c, kugo2p__PriceBookName__c, kugo2p__DateRequired__c, kugo2p__ServiceDateRequired__c, kugo2p__PaymentTerms__c,' + 
                                       'kugo2p__BillingFrequency__c, kugo2p__RecordStatus__c, kugo2p__PaymentMethod__c, kugo2p__DiscountPercent__c, kugo2p__BalanceDueAmount__c, kugo2p__WareHouse__c, kugo2p__IsPrimary__c ' +
                                ' from kugo2p__SalesOrder__c where Id = :soId');
    }

    public static void DataSetup() {
        kugo2p.Kugamon.TestMode = true;

        // this is a workaround solution to enable Standard Price Book
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;

        // create Kugamon Settings
        Assert.isNotNull(Settings.Id);              

        Assert.isFalse(Products.isEmpty());
        Assert.isFalse(APDs.isEmpty());

        Assert.isFalse(tiers.isEmpty());

        // create oppty and line items
        Assert.isFalse(oppLineItems.isEmpty());

        // create sales quote, product and service lines
        Assert.isFalse(QuoteProductLines.isEmpty());
        Assert.isFalse(QuoteServiceLines.isEmpty());
        Assert.isFalse(QuoteOptionalLines.isEmpty());

        // create sales order, product and service lines
        Assert.isFalse(OrderProductLines.isEmpty());
        Assert.isFalse(OrderServiceLines.isEmpty());

        // create Quote and Order Acc lines 
        Assert.isFalse(QuoteACCs.isEmpty());
        Assert.isFalse(OrderACCs.isEmpty());
        
        // create invoice and its relationship
        Assert.isNotNull(Invoice.Id);
        Assert.isFalse(InvoiceLines.isEmpty());
        Assert.isFalse(InvoiceACCs.isEmpty());
        
        kugo2p__OrderInvoiceRelationship__c oir = new kugo2p__OrderInvoiceRelationship__c(kugo2p__Invoice__c=Invoice.Id, kugo2p__SalesOrder__c=SalesOrder.Id);
        insert oir;
    }

    public static String StandardPriceBookName = 'Standard Price Book';
    public static Id StandardPriceBookId {
        get {
            if (StandardPriceBookId == null) {
                StandardPriceBookId = Test.getStandardPricebookId();
            }
            return StandardPriceBookId;
        }
        private set;
    }

    public static Pricebook2 CustomPriceBook {
        get {
            if (CustomPriceBook == null) {
                CustomPriceBook = new Pricebook2(Name='Test pricebook', IsActive=true, Description='Test');
                insert CustomPriceBook;
            }
            return CustomPriceBook;
        }

        private set;
    }
    
    public static kugo2p__KugamonSetting__c Settings {
        get {
            if (Settings == null) {
                Settings = new kugo2p__KugamonSetting__c(Name = 'My Org Setting', kugo2p__PriceBookName__c = CustomPriceBook.Name,
                                                        kugo2p__PrintSpecificTextandTerms__c = false,
                                                        kugo2p__UnitOfMeasure__c = 'Each', kugo2p__TaxableExcise__c = false, kugo2p__TaxableSales__c = true, 
                                                        kugo2p__TaxableUsage__c = false, kugo2p__TaxableVat__c = false,
                                                        kugo2p__CompanyTextAndTerms__c = 'This legally binding Order Form is governed by the Master Subscription Agreement between Customer and Kugamon LLC. Prices shown do not include any taxes that may apply. Any such taxes are the responsibility of Customer. Sandbox subscriptions, if ordered, are for testing and development use only and not for production use. Subscriptions are non-cancelable before their End Date.', 
                                                        kugo2p__PrintCompanyTextAndTerms__c = true, kugo2p__SpecificTextandTerms__c='Specific Terms & Conditions',
                                                        kugo2p__PrintInvoiceTextandTerms__c=true, kugo2p__InvoiceTextandTerms__c='Invoice Terms', 
                                                        kugo2p__PaymentMethod__c='Debit/Credit Card', kugo2p__PaymentTerms__c='Due Upon Receipt', kugo2p__DaysTillPaymentDue__c=0,
                                                        kugo2p__Admin_User__c=UserInfo.getUserId(), kugo2p__OnlinePaymentButton__c='Accept & Pay', kugo2p__OnlineConfirmationTextandTerms__c='Confirmation Text',
                                                        kugo2p__SyncPrimaryQuotetoOpportunityAmount__c=true, kugo2p__UpdateOpportunityAmountBasis__c='Total Amount + Additional Charges/Credit Amount',
                                                        kugo2p__SyncPrimaryOrdertoOpportunityAmount__c=false, kugo2p__SyncPrimaryQuotetoOpportunityLines__c='Quote Draft;Quote Sent;Quote Won',
                                                        kugo2p__SyncPrimaryOrdertoOpportunityLines__c='Order Draft;Order Sent;Order Approved;Order Released');
                insert Settings;

                Settings.kugo2p__WareHouse__c = warehouse.Id;
                update Settings;

            }
            return Settings;
        }
        private set;
    }

    public static kugo2p__WareHouse__c warehouse {
        get {
            if (warehouse == null) {
                warehouse = new kugo2p__WareHouse__c(Name = 'Test Main', kugo2p__KugamonSetting__c=Settings.Id, kugo2p__Description__c = 'Main Warehouse', 
                                                    kugo2p__WarehouseStreet__c = '900 Stanyan St', kugo2p__WareHouseCity__c = 'San Fransisco', kugo2p__WareHouseStateProvince__c = 'California', 
                                                    kugo2p__WareHouseZipPostalCode__c = '94117', kugo2p__WareHouseCountry__c = 'United States');
                insert warehouse;
            }
            return warehouse;
        }
        private set;
    }   

    public static list<Product2> Products {
        get {
            if (Products == null) {

                Products = new list<Product2> {
                    new Product2(Name = 'Test GenWatt Bundle', ProductCode = 'GC1040', Family = 'Test Product', IsActive = true),
                    new Product2(Name = 'Test Service Bundle', ProductCode = 'GC1041', Family = 'Test Service', IsActive = true),

                    new Product2(Name = 'Kit Member Product 1', ProductCode = 'GC1042', Family = 'Test Product', IsActive = true),
                    new Product2(Name = 'Kit Member Service 1', ProductCode = 'GC1043', Family = 'Test Service', IsActive = true),
                    new Product2(Name = 'Complex Product 1', ProductCode = 'CP0001', Family = 'Test Complex Product', IsActive = true)
                };

                insert Products;

                Assert.isTrue(APDs.size() > 0);
                Assert.isFalse(PricebookEntries.isEmpty());
            }
            return Products;
        }
        private set;
    }

    //  Hardware
    public static list<kugo2p__ConfigurationGroup__c> ConfigurationGroups {
        get {
            if (ConfigurationGroups == null) {

                ConfigurationGroups = new list<kugo2p__ConfigurationGroup__c> {
                    new kugo2p__ConfigurationGroup__c(kugo2p__AdditionalProductInfo__c = APDs[4].Id, kugo2p__Category__c = 'Hardware', kugo2p__MinimumOption__c = 1, kugo2p__MaximumOption__c = 5, kugo2p__SortOrder__c = 1)
                };

                insert ConfigurationGroups;

                Assert.isTrue(ConfigurationGroups.size() > 0);
            }
            return ConfigurationGroups;
        }
        private set;
    }

    public static list<kugo2p__ConfigurationOption__c> ConfigurationOptions {
        get {
            if (ConfigurationOptions == null) {

                ConfigurationOptions = new list<kugo2p__ConfigurationOption__c> {
                    new kugo2p__ConfigurationOption__c(kugo2p__ConfigurationGroup__c = ConfigurationGroups[0].Id, kugo2p__ConfigureProduct__c = APDs[4].Id, kugo2p__OptionProduct__c = APDs[0].Id, kugo2p__Required__c = true, kugo2p__Selected__c = true, kugo2p__SortOrder__c = 1)
                };

                insert ConfigurationOptions;

                Assert.isTrue(ConfigurationOptions.size() > 0);
            }
            return ConfigurationOptions;
        }
        private set;
    }

    public static list<kugo2p__AdditionalProductDetail__c> APDs {
        get {
            if (APDs == null) {
                APDs = [Select Id, Name, kugo2p__ProductDescription__c, kugo2p__ProductFamily__c, kugo2p__ReferenceProduct__c, kugo2p__Service__c, kugo2p__UnitofMeasure__c, kugo2p__UnitofTerm__c, kugo2p__StandardPrice__c, kugo2p__UnitCost__c, kugo2p__Active__c 
                          From kugo2p__AdditionalProductDetail__c 
                          Where kugo2p__ReferenceProduct__c in : Products];

                System.debug('APDs.size(): ' + APDs.size());
                
                // Product - Bundle
                APDs[0].kugo2p__Service__c = false; 
                APDs[0].kugo2p__PrintProductTextandTerms__c = true;
                APDs[0].kugo2p__KitBundle__c = true;
                APDs[0].kugo2p__KitBundlePricing__c = 'Member Prices Only';
                APDs[0].kugo2p__CreateAsset__c = 'Per Quantity';
                APDs[0].kugo2p__ConfigurationMethod__c = 'Kit/Bundle';
                APDs[0].kugo2p__ConfigurationType__c = 'Required';
                APDs[0].kugo2p__ConfigurationAction__c = 'Always';
                APDs[0].kugo2p__QuantityScale__c = '1'; 
                APDs[0].kugo2p__ServiceTermScale__c = '1';

                // Service - Bundle
                APDs[1].kugo2p__Service__c = true;
                APDs[1].kugo2p__UnitofTerm__c = 'Month';
                APDs[1].kugo2p__PrintProductTextandTerms__c = true;
                APDs[1].kugo2p__KitBundle__c = true;
                APDs[1].kugo2p__KitBundlePricing__c = 'Member Prices Only';
                APDs[1].kugo2p__PricingMethod__c = 'Cost';
                APDs[1].kugo2p__DefaultCostMarkupPercent__c = 10;
                APDs[1].kugo2p__QuantityScale__c = '1';
                APDs[1].kugo2p__ServiceTermScale__c = '1';

                // Product - Kit Member
                APDs[2].kugo2p__Service__c = false;
                APDs[2].kugo2p__PrintProductTextandTerms__c = true;
                APDs[2].kugo2p__CreateAsset__c = 'Per Quantity';
                APDs[2].kugo2p__QuantityScale__c = '2';
                APDs[2].kugo2p__ServiceTermScale__c = '2';

                // Service - Kit Member
                APDs[3].kugo2p__Service__c = true;
                APDs[3].kugo2p__UnitofTerm__c = 'Month';
                APDs[3].kugo2p__PrintProductTextandTerms__c = true;
                APDs[3].kugo2p__QuantityScale__c = '3';
                APDs[3].kugo2p__ServiceTermScale__c = '3';

                // Product - Bundle
                APDs[4].kugo2p__Service__c = false; 
                APDs[4].kugo2p__ConfigurationMethod__c = 'Configure';
                APDs[4].kugo2p__ConfigurationType__c = 'Required';
                APDs[4].kugo2p__ConfigurationAction__c = 'Always';
                APDs[4].kugo2p__QuantityScale__c = '4';
                APDs[4].kugo2p__ServiceTermScale__c = '4';

                update APDs;
            }
            return APDs;
        }
        private set;
    }

    public static list<PricebookEntry> PricebookEntries {
        get {
            if (PricebookEntries == null) {
                PricebookEntries = new list<PricebookEntry> {
                    // kit Bundle
                    new PricebookEntry(Product2Id = Products[0].Id, Pricebook2Id = StandardPriceBookId, IsActive = true, UseStandardPrice = false, UnitPrice = 10),  
                    new PricebookEntry(Product2Id = Products[1].Id, Pricebook2Id = StandardPriceBookId, IsActive = true, UseStandardPrice = false, UnitPrice = 20),

                    new PricebookEntry(Product2Id = Products[0].Id, Pricebook2Id = CustomPriceBook.Id, IsActive = true, UseStandardPrice = false, UnitPrice = 100),
                    new PricebookEntry(Product2Id = Products[1].Id, Pricebook2Id = CustomPriceBook.Id, IsActive = true, UseStandardPrice = false, UnitPrice = 200),

                    // kit Members
                    new PricebookEntry(Product2Id = Products[2].Id, Pricebook2Id = StandardPriceBookId, IsActive = true, UseStandardPrice = false, UnitPrice = 30),  
                    new PricebookEntry(Product2Id = Products[3].Id, Pricebook2Id = StandardPriceBookId, IsActive = true, UseStandardPrice = false, UnitPrice = 40),

                    new PricebookEntry(Product2Id = Products[2].Id, Pricebook2Id = CustomPriceBook.Id, IsActive = true, UseStandardPrice = false, UnitPrice = 300),
                    new PricebookEntry(Product2Id = Products[3].Id, Pricebook2Id = CustomPriceBook.Id, IsActive = true, UseStandardPrice = false, UnitPrice = 400),

                    // complex product
                    new PricebookEntry(Product2Id = Products[4].Id, Pricebook2Id = StandardPriceBookId, IsActive = true, UseStandardPrice = false, UnitPrice = 30),  

                    new PricebookEntry(Product2Id = Products[4].Id, Pricebook2Id = CustomPriceBook.Id, IsActive = true, UseStandardPrice = false, UnitPrice = 300)

                };
                insert PricebookEntries;
            }
            return PricebookEntries;
        }
        private set;
    }

    public static list<kugo2p__TieredPricing__c> tieredPricings {
        get {
            if (tieredPricings == null) {
                tieredPricings = new list<kugo2p__TieredPricing__c> {
                    new kugo2p__TieredPricing__c(Name='Summer Product pricing', kugo2p__IsActive__c=true, kugo2p__PriceBook__c=CustomPriceBook.Id, kugo2p__Product__c=Products[0].Id, kugo2p__Type__c='Volume'),
                    new kugo2p__TieredPricing__c(Name='Summer Service pricing', kugo2p__IsActive__c=true, kugo2p__PriceBook__c=CustomPriceBook.Id, kugo2p__Product__c=Products[1].Id, kugo2p__Type__c='Slab')
                };
                insert tieredPricings;
            }
            return tieredPricings;
        }
        private set;
    }

    public static list<kugo2p__Tier__c> tiers {
        get {
            if (tiers == null) {
                tiers = new list<kugo2p__Tier__c> {
                    new kugo2p__Tier__c(kugo2p__TieredPricing__c=tieredPricings[0].Id, kugo2p__QuantityStart__c=10, kugo2p__TierPrice__c=10.00),
                    new kugo2p__Tier__c(kugo2p__TieredPricing__c=tieredPricings[0].Id, kugo2p__QuantityStart__c=20, kugo2p__TierPrice__c=20.00),
                    new kugo2p__Tier__c(kugo2p__TieredPricing__c=tieredPricings[0].Id, kugo2p__QuantityStart__c=30, kugo2p__TierPrice__c=30.00),

                    new kugo2p__Tier__c(kugo2p__TieredPricing__c=tieredPricings[1].Id, kugo2p__QuantityStart__c=100, kugo2p__TierPrice__c=15.00),
                    new kugo2p__Tier__c(kugo2p__TieredPricing__c=tieredPricings[1].Id, kugo2p__QuantityStart__c=200, kugo2p__TierPrice__c=25.00),
                    new kugo2p__Tier__c(kugo2p__TieredPricing__c=tieredPricings[1].Id, kugo2p__QuantityStart__c=300, kugo2p__TierPrice__c=35.00)
                };
                insert tiers;
            }
            return tiers;
        }
        private set;
    }

    public static list<kugo2p__KitBundleMember__c> kitBundleMembers {
        get {
            if (kitBundleMembers == null) {
                kitBundleMembers = new List<kugo2p__KitBundleMember__c> {
                    // Product Kit members
                    new kugo2p__KitBundleMember__c(kugo2p__ReferenceKitBundle__c = APDs[0].Id, kugo2p__ReferenceMemberProductService__c = APDs[2].Id, kugo2p__AllowQuantityChange__c = true, kugo2p__Required__c = true, kugo2p__Quantity__c = 1),
                    new kugo2p__KitBundleMember__c(kugo2p__ReferenceKitBundle__c = APDs[0].Id, kugo2p__ReferenceMemberProductService__c = APDs[3].Id, kugo2p__AllowQuantityChange__c = false, kugo2p__Required__c = false, kugo2p__Quantity__c = 1),

                    // Service Kit members
                    new kugo2p__KitBundleMember__c(kugo2p__ReferenceKitBundle__c = APDs[1].Id, kugo2p__ReferenceMemberProductService__c = APDs[3].Id, kugo2p__AllowQuantityChange__c = false, kugo2p__Required__c = true, kugo2p__Quantity__c = 1)
                };

                insert kitBundleMembers;
            }

            return kitBundleMembers;
        }
        private set;
    }    

    public static Account account {
        get {
            if (account == null) {
                account = new Account(Name = 'Test Account',Type = 'Customer - Direct',BillingStreet = '3545 Ave',BillingState = 'CA',
                                              BillingPostalCode = '95050',BillingCountry = 'USA',ShippingStreet = '525 Ave',ShippingCity = 'San Jose',
                                              ShippingState = 'CA',ShippingPostalCode = '95050',ShippingCountry = 'USA',Phone = '(336) 222-7000',
                                              Fax ='(336) 222-8000',AccountNumber = 'Test ANo',Website = 'www.kkk.com',Industry = 'Apparel',
                                              AnnualRevenue = 350000000,NumberOfEmployees = 9000,Ownership = 'Public',TickerSymbol = 'BTXT',
                                              Description = 'Test Account',Site = '');
                insert account;
            }
            return account;
        }
        private set;
    }

    public static kugo2p__AdditionalAccountDetail__c AdditionalAccountDetail {
        get {
            if (AdditionalAccountDetail == null) {
                AdditionalAccountDetail = [select Id, kugo2p__PricebookName__c from kugo2p__AdditionalAccountDetail__c where kugo2p__Account__c = :account.Id];
                AdditionalAccountDetail.kugo2p__PricebookName__c = CustomPriceBook.Name;
                //AdditionalAccountDetail.kugo2p__Warehouse__c = warehouse.Id;
                AdditionalAccountDetail.kugo2p__PaymentMethod__c = 'Check';
                AdditionalAccountDetail.kugo2p__ContactBilling__c = contact.Id;
                AdditionalAccountDetail.kugo2p__ContactBuying__c = contact.Id;

                update AdditionalAccountDetail;
            }
            return AdditionalAccountDetail;
        }
        private set;
    }

    public static list<kugo2p__AccountPricing__c> accountPricings {
        get {
            if (accountPricings == null) {
                accountPricings = new list<kugo2p__AccountPricing__c> {
                    new kugo2p__AccountPricing__c(kugo2p__Account__c = account.Id, kugo2p__ProductService__c = APDs[0].Id, kugo2p__Price__c = 123.45, kugo2p__Discount__c = null, kugo2p__LockSalesPrice__c = true, kugo2p__LockLineDiscount__c = true, kugo2p__Hide__c = false),
                    new kugo2p__AccountPricing__c(kugo2p__Account__c = account.Id, kugo2p__ProductService__c = APDs[0].Id, kugo2p__Price__c = 678.90, kugo2p__Discount__c = null, kugo2p__LockSalesPrice__c = true, kugo2p__LockLineDiscount__c = true, kugo2p__Hide__c = false),
                    new kugo2p__AccountPricing__c(kugo2p__Account__c = account.Id, kugo2p__ProductService__c = null, kugo2p__Price__c = null, kugo2p__Discount__c = 10.45, kugo2p__LockSalesPrice__c = true, kugo2p__LockLineDiscount__c = true, 
                                                    kugo2p__FilterObject__c = 'Product', kugo2p__Operator__c = 'contains', kugo2p__FilterField__c = 'Name', kugo2p__FilterValue__c = Products[0].Name.left(4), kugo2p__Hide__c  = false)
                };
                
                insert accountPricings;
            }
            return accountPricings;
        }
        private set;
    }   

    public static Contact contact {
        get {
            if (contact == null) {
                contact = new Contact(AccountId=account.Id, FirstName='Will', LastName='Smith', Phone='333-333-3333', MailingStreet='1 Kugamon Street', MailingState='CA', MailingCity='SF', MailingPostalCode='95050', MailingCountry='US');
                insert contact;
            }
            return contact;
        }
        private set;
    }
    
    public static Opportunity opportunity {
        get {
            if (opportunity == null) {
                OpportunityStage stage = [Select MasterLabel From OpportunityStage Where isActive=true Limit 1];
                System.debug(' ### Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
                opportunity = new Opportunity(Name = 'Test Opp', AccountId = account.Id, StageName = stage.MasterLabel, CloseDate = System.today().addDays(-15), PriceBook2Id = CustomPriceBook.Id);
                insert opportunity;
            }
            return opportunity;
        }
        private set;
    }
    
    public static list<OpportunityLineItem> oppLineItems {
        get {
            if (oppLineItems == null) {
                oppLineItems = new list<OpportunityLineItem> {
                  new OpportunityLineItem(Description='Item 1', OpportunityId=opportunity.Id, Quantity=1, ServiceDate=System.today(), pricebookEntryId=PricebookEntries[2].Id, TotalPrice=100),  
                  new OpportunityLineItem(Description='Item 2', OpportunityId=opportunity.Id, Quantity=2, ServiceDate=System.today(), pricebookEntryId=PricebookEntries[3].Id, TotalPrice=100)
                };
                insert oppLineItems;
            }
            return oppLineItems;
        }
        private set;
    }   

    public static kugo2p__SalesOrder__c SalesOrder {
        get {
            if (SalesOrder == null) {
                SalesOrder = new kugo2p__SalesOrder__c(kugo2p__Account__c = account.Id, kugo2p__Opportunity__c = opportunity.Id, kugo2p__OrderDate__c = System.today(),
                                                kugo2p__PriceBookName__c = CustomPriceBook.Name, kugo2p__DiscountPercent__c=null, kugo2p__PaymentMethod__c='Paypal',
                                                kugo2p__ContactShipping__c=contact.Id, kugo2p__ContactBuying__c=contact.Id, kugo2p__ContactBilling__c=contact.Id, kugo2p__RecordStatus__c='Draft');
                insert SalesOrder;
            }
            return SalesOrder;
        }
        public set;
    }

    public static list<kugo2p__SalesOrderProductLine__c> OrderProductLines {
        get {
            if (OrderProductLines == null) {
                OrderProductLines = new list<kugo2p__SalesOrderProductLine__c> {
                  new kugo2p__SalesOrderProductLine__c(kugo2p__LineDescription__c = 'Item 1', kugo2p__SalesOrder__c = SalesOrder.id, kugo2p__Quantity__c = 10, kugo2p__Product__c=APDs[0].Id, 
                                                        kugo2p__DateAvailableToPromise__c=System.today(), kugo2p__DateRequired__c = System.today(), kugo2p__ContactShipping__c=contact.Id, 
                                                        kugo2p__OpportunityLineItemId__c=oppLineItems[0].Id, kugo2p__OpportunityLineItem__c=oppLineItems[0].Id, kugo2p__SalesQuoteProductLine__c=QuoteProductLines[0].Id, kugo2p__Warehouse__c = warehouse.Id, kugo2p__PricingMethod__c = 'List'),

                  new kugo2p__SalesOrderProductLine__c(kugo2p__LineDescription__c = 'Item 1', kugo2p__SalesOrder__c = SalesOrder.id, kugo2p__Quantity__c = 10, kugo2p__Product__c=APDs[4].Id, 
                                                        kugo2p__DateAvailableToPromise__c=System.today(), kugo2p__DateRequired__c = System.today(), kugo2p__ContactShipping__c=contact.Id, 
                                                        kugo2p__SalesQuoteProductLine__c=QuoteProductLines[0].Id, kugo2p__Warehouse__c = warehouse.Id, kugo2p__PricingMethod__c = 'Cost', kugo2p__CostMarkupAmount__c = 0)
                };
                insert OrderProductLines;

                OrderProductLines = [Select Id, Name, kugo2p__SalesOrder__c, kugo2p__LineDescription__c, kugo2p__Quantity__c, kugo2p__ListPrice__c, kugo2p__SalesPrice__c, kugo2p__Product__c, kugo2p__DateRequired__c, 
                                            kugo2p__ContactShipping__c, kugo2p__OpportunityLineItemId__c, kugo2p__OpportunityLineItem__c, kugo2p__SalesQuoteProductLine__c, kugo2p__SalesOrder__r.kugo2p__Account__c, 
                                            kugo2p__Product__r.kugo2p__ReferenceProduct__r.Name, kugo2p__SalesOrder__r.kugo2p__ContactBuying__c, kugo2p__Product__r.kugo2p__ReferenceProduct__c, kugo2p__DiscountSalesPrice__c,
                                            kugo2p__DateAvailableToPromise__c, kugo2p__Warehouse__c
                                     from   kugo2p__SalesOrderProductLine__c
                                     where  Id in :OrderProductLines];

                boolean updateSOPLs = false;
                for (kugo2p__SalesOrderProductLine__c sopl : OrderProductLines) {
                    if (sopl.kugo2p__Warehouse__c != warehouse.Id) {
                        updateSOPLs = true;
                        sopl.kugo2p__Warehouse__c = warehouse.Id;
                    }
                }
                System.debug(' ### updateSOPLs ' + updateSOPLs);
                if (updateSOPLs) update OrderProductLines;
            }
            return OrderProductLines;
        }
        private set;
    }
    
    public static list<kugo2p__SalesOrderServiceLine__c> OrderServiceLines {
        get {
            if (OrderServiceLines == null) {
                OrderServiceLines = new list<kugo2p__SalesOrderServiceLine__c> { 
                    new kugo2p__SalesOrderServiceLine__c(kugo2p__LineDescription__c = 'Item 2', kugo2p__SalesOrder__c = SalesOrder.Id, kugo2p__Quantity__c = 2, kugo2p__Service__c=APDs[1].Id, 
                                                        kugo2p__DateServiceStart__c = System.today(), kugo2p__DateServiceEnd__c = System.today().addMonths(2), kugo2p__ServiceTerm__c=2, 
                                                        kugo2p__SalesQuoteServiceLine__c=QuoteServiceLines[0].Id, kugo2p__PricingMethod__c = 'List'),
                    new kugo2p__SalesOrderServiceLine__c(kugo2p__LineDescription__c = 'Item 2', kugo2p__SalesOrder__c = SalesOrder.Id, kugo2p__Quantity__c = 2, kugo2p__Service__c=APDs[1].Id, 
                                                        kugo2p__DateServiceStart__c = System.today(), kugo2p__DateServiceEnd__c = System.today().addMonths(2), kugo2p__ServiceTerm__c=2, 
                                                        kugo2p__SalesQuoteServiceLine__c=QuoteServiceLines[0].Id, kugo2p__PricingMethod__c = 'Cost', kugo2p__CostMarkupAmount__c = 0)
                };

                insert OrderServiceLines;

                SalesOrder = getSalesOrder(SalesOrder.Id);
                //System.debug(' ### SalesOrder ' + SalesOrder.kugo2p__PriceBookName__c + ' => ' + SalesOrder);
            }
            return OrderServiceLines;
        }
        private set;
    }   

    public static list<kugo2p__AdditionalChargeCredit__c> accs {
        get {
            if (accs == null) {
                accs = new list<kugo2p__AdditionalChargeCredit__c> {
                    new kugo2p__AdditionalChargeCredit__c(Name='Shipping Fee', kugo2p__UnitPrice__c=25, kugo2p__IsActive__c=true, kugo2p__OpportunitySyncProduct__c=APDs[0].Id),
                    new kugo2p__AdditionalChargeCredit__c(Name='Late Fee', kugo2p__UnitPrice__c=50, kugo2p__IsActive__c=true, kugo2p__OpportunitySyncProduct__c=APDs[1].Id)
                };

                insert accs;
            }
            return accs;
        }
        private set;
    }
    
    public static list<kugo2p__SalesQuoteAdditionalChargeCredit__c> QuoteACCs {
        get {
            if (QuoteACCs == null) {
                QuoteACCs = new list<kugo2p__SalesQuoteAdditionalChargeCredit__c> {
                    new kugo2p__SalesQuoteAdditionalChargeCredit__c(kugo2p__AdditionalChargeCredit__c = accs[0].Id, kugo2p__SalesQuote__c = SalesQuote.Id, kugo2p__Quantity__c = 1, kugo2p__LineDescription__c = 'Acc Desc 1'),
                    new kugo2p__SalesQuoteAdditionalChargeCredit__c(kugo2p__AdditionalChargeCredit__c = accs[1].Id, kugo2p__SalesQuote__c = SalesQuote.Id, kugo2p__Quantity__c = 2, kugo2p__LineDescription__c = 'Acc Desc 2')
                };
                insert QuoteACCs;
            }
            return QuoteACCs;
        }
        private set;
    }

    public static list<kugo2p__SalesOrderAdditionalChargeCredit__c> OrderACCs {
        get {
            if (OrderACCs == null) {
                OrderACCs = new list<kugo2p__SalesOrderAdditionalChargeCredit__c> {
                    new kugo2p__SalesOrderAdditionalChargeCredit__c(kugo2p__AdditionalChargeCredit__c = accs[0].Id, kugo2p__SalesOrder__c = SalesOrder.Id, kugo2p__Quantity__c = 1, kugo2p__LineDescription__c = 'Acc Desc 1'),
                    new kugo2p__SalesOrderAdditionalChargeCredit__c(kugo2p__AdditionalChargeCredit__c = accs[1].Id, kugo2p__SalesOrder__c = SalesOrder.Id, kugo2p__Quantity__c = 2, kugo2p__LineDescription__c = 'Acc Desc 2')
                };
                insert OrderACCs;
            }
            return OrderACCs;
        }
        private set;
    }

    public static kugo2p__SalesQuote__c SalesQuote {
        get {
            if (SalesQuote == null) {
                SalesQuote = new kugo2p__SalesQuote__c(kugo2p__Account__c = Account.Id, kugo2p__Opportunity__c = opportunity.Id, kugo2p__PriceBookName__c = CustomPriceBook.Name);
                insert SalesQuote;

                SalesQuote = getSalesQuote(SalesQuote.Id);
            }
            return SalesQuote;
        }
        public set;
    }
    
    public static list<kugo2p__SalesQuoteProductLine__c> QuoteProductLines {
        get {
            if (QuoteProductLines == null) {
                QuoteProductLines = new list<kugo2p__SalesQuoteProductLine__c> {
                    new kugo2p__SalesQuoteProductLine__c(kugo2p__LineDescription__c = 'Item 1', kugo2p__SalesQuote__c = SalesQuote.Id, kugo2p__Quantity__c = 1, kugo2p__Product__c=APDs[0].Id, kugo2p__DateRequired__c = System.today().addMonths(2), kugo2p__OpportunityLineItemId__c = oppLineItems[0].Id, kugo2p__OpportunityLineItem__c = oppLineItems[0].Id)
                };
                insert QuoteProductLines;
            }

            return QuoteProductLines;
        }
        private set;
    }

    public static list<kugo2p__SalesQuoteServiceLine__c> QuoteServiceLines {
        get {
            if (QuoteServiceLines == null) {
                QuoteServiceLines = new list<kugo2p__SalesQuoteServiceLine__c> {
                    new kugo2p__SalesQuoteServiceLine__c(kugo2p__LineDescription__c = 'Item 2', kugo2p__SalesQuote__c = SalesQuote.Id, kugo2p__Quantity__c = 3, kugo2p__Service__c=APDs[1].Id, kugo2p__DateServiceStart__c = System.today().addMonths(2), kugo2p__DateServiceEnd__c = System.today().addMonths(4), kugo2p__ServiceTerm__c = 2, kugo2p__OpportunityLineItemId__c = oppLineItems[1].Id, kugo2p__OpportunityLineItem__c = oppLineItems[1].Id)
                };
                insert QuoteServiceLines;
            }

            return QuoteServiceLines;
        }
        private set;
    }

    public static list<kugo2p__SalesQuoteOptionalLine__c> QuoteOptionalLines {
        get {
            if (QuoteOptionalLines == null) {
                QuoteOptionalLines = new list<kugo2p__SalesQuoteOptionalLine__c> {
                    new kugo2p__SalesQuoteOptionalLine__c(kugo2p__SalesQuote__c = SalesQuote.Id, kugo2p__ProductService__c = apds[0].Id, kugo2p__ListPrice__c = 100, kugo2p__SalesPrice__c = 85, kugo2p__LineDescription__c = 'Optional product'),
                    new kugo2p__SalesQuoteOptionalLine__c(kugo2p__SalesQuote__c = SalesQuote.Id, kugo2p__ProductService__c = apds[1].Id, kugo2p__ListPrice__c = 100, kugo2p__SalesPrice__c = 85, kugo2p__LineDescription__c = 'Optional service')
                };
                insert QuoteOptionalLines;
            }
            return QuoteOptionalLines;
        }
        private set;
    }

    public static kugo2p__KugamonInvoice__c Invoice {
        get {
            if (Invoice == null) {
                Invoice = new kugo2p__KugamonInvoice__c(kugo2p__Account__c=Account.Id, kugo2p__InvoiceDate__c=Date.today(), kugo2p__InvoiceDueDate__c=Date.today().addDays(4));
                insert invoice;
            }
            return Invoice;
        }
        private set;
    }

    public static list<kugo2p__KugamonInvoiceLine__c> InvoiceLines {
        get {
            if (InvoiceLines == null) {
                InvoiceLines = new list<kugo2p__KugamonInvoiceLine__c> {
                    new kugo2p__KugamonInvoiceLine__c(kugo2p__Invoice__c = Invoice.Id, kugo2p__SalesOrder__c = SalesOrder.Id, kugo2p__SalesOrderProductLine__c = OrderProductLines[0].Id,
                                        kugo2p__ProductService__c = apds[0].Id, kugo2p__UnitOfMeasure__c = apds[0].kugo2p__UnitOfMeasure__c, kugo2p__UnitOfTerm__c = apds[0].kugo2p__UnitOfTerm__c,
                                        kugo2p__CalculatedQuantity__c = 1, kugo2p__Quantity__c = 1, kugo2p__LineDescription__c = OrderProductLines[0].kugo2p__LineDescription__c),

                    new kugo2p__KugamonInvoiceLine__c(kugo2p__Invoice__c = Invoice.Id, kugo2p__SalesOrder__c = SalesOrder.Id, kugo2p__SalesOrderServiceLine__c = OrderServiceLines[0].Id,
                                        kugo2p__ProductService__c = apds[1].Id, kugo2p__UnitOfMeasure__c = apds[1].kugo2p__UnitOfMeasure__c, kugo2p__UnitOfTerm__c = apds[1].kugo2p__UnitOfTerm__c,
                                        kugo2p__CalculatedQuantity__c = 1, kugo2p__Quantity__c = 1, kugo2p__LineDescription__c = OrderServiceLines[0].kugo2p__LineDescription__c)
                };
                insert InvoiceLines;
            }
            return InvoiceLines;
        }
        private set;
    }

    public static list<kugo2p__KugamonInvoiceAdditionalChargeCredit__c> InvoiceACCs {
        get {
            if (InvoiceACCs == null) {
                InvoiceACCs = new list<kugo2p__KugamonInvoiceAdditionalChargeCredit__c> {
                    new kugo2p__KugamonInvoiceAdditionalChargeCredit__c(kugo2p__AdditionalChargeCredit__c = accs[0].Id, kugo2p__Invoice__c = Invoice.Id, kugo2p__Quantity__c = 1, kugo2p__LineDescription__c = 'Acc Desc 1'),
                    new kugo2p__KugamonInvoiceAdditionalChargeCredit__c(kugo2p__AdditionalChargeCredit__c = accs[1].Id, kugo2p__Invoice__c = Invoice.Id, kugo2p__Quantity__c = 2, kugo2p__LineDescription__c = 'Acc Desc 2')
                };
                insert InvoiceACCs;
            }
            return InvoiceACCs;
        }
        private set;
    }
 
    public static kugo2p__Payment_Profile__c RecurringCharge {
        get {
            if (RecurringCharge == null) {
                 RecurringCharge = new kugo2p__Payment_Profile__c( Name = 'Test Profile',
                                                                kugo2p__AuthNet_Subscription_Id__c = '13224sskjfs',
                                                                kugo2p__SalesOrder__c = salesOrder.Id,
                                                                kugo2p__Contact__c = contact.Id,
                                                                kugo2p__Amount__c = salesOrder.kugo2p__BalanceDueAmount__c,
                                                                kugo2p__Subscription_Status__c = 'Not Active',
                                                                kugo2p__Frequency__c = 1,
                                                                kugo2p__Period__c = 'Month',
                                                                kugo2p__Total_Occurrences__c = 1);

                insert RecurringCharge;
            }
            return RecurringCharge;
        }
        private set;
    }   

    public static list<Asset> assets {
        get {
            if (assets == null) {
                assets = new List<Asset> {
                    // Product Kit members
                    new Asset(Name = 'Test Asset', Product2Id = APDs[0].kugo2p__ReferenceProduct__c, AccountId = account.Id, kugo2p__OrderProductLine__c = OrderProductLines[0].Id, Quantity = 1),
                    // Complex products
                    new Asset(Name = 'Test Asset 2', Product2Id = APDs[2].kugo2p__ReferenceProduct__c, AccountId = account.Id, kugo2p__OrderProductLine__c = OrderProductLines[1].Id, Quantity = 1)
                };

                insert assets;
            }

            return assets;
        }
        private set;
    }
    
    public static list<kugo2p__QuoteLineGroup__c> QuoteLineGroups {
        get {
            if (quoteLineGroups == null) {
                quoteLineGroups = new List<kugo2p__QuoteLineGroup__c> {
                    new kugo2p__QuoteLineGroup__c(Name = 'Test Group 1', kugo2p__GroupDescription__c = '', kugo2p__SalesQuote__c = SalesQuote.Id),
                    new kugo2p__QuoteLineGroup__c(Name = 'Test Group 2', kugo2p__GroupDescription__c = '', kugo2p__SalesQuote__c = SalesQuote.Id)
                };

                insert quoteLineGroups;
            }

            return quoteLineGroups;
        }
        private set;
    }

    public static list<kugo2p__OrderLineGroup__c> OrderLineGroups {
        get {
            if (orderLineGroups == null) {
                orderLineGroups = new List<kugo2p__OrderLineGroup__c> {
                    new kugo2p__OrderLineGroup__c(Name = 'Test Group 1', kugo2p__GroupDescription__c = '', kugo2p__SalesOrder__c = SalesOrder.Id),
                    new kugo2p__OrderLineGroup__c(Name = 'Test Group 1', kugo2p__GroupDescription__c = '', kugo2p__SalesOrder__c = SalesOrder.Id)
                };

                insert orderLineGroups;
            }

            return orderLineGroups;
        }
        private set;
    }

    public static list<kugo2p__Favorite__c> favoriteGroups {
        get {
            if (favoriteGroups == null) {
                favoriteGroups = new List<kugo2p__Favorite__c> {
                    new kugo2p__Favorite__c(Name = 'Test Favorite Group 1', kugo2p__IsGroup__c = true, OwnerId = UserInfo.getUserId()),
                    new kugo2p__Favorite__c(Name = 'Test Favorite Group 2', kugo2p__IsGroup__c = true, OwnerId = UserInfo.getUserId())
                };

                insert favoriteGroups;
            }

            return favoriteGroups;
        }
        private set;
    }
    
    public static list<kugo2p__FavoriteMember__c> FavoriteGroupMembers {
        get {
            if (favoriteGroupMembers == null) {
                favoriteGroupMembers = new List<kugo2p__FavoriteMember__c> {
                    new kugo2p__FavoriteMember__c(kugo2p__Product__c = APDs[0].kugo2p__ReferenceProduct__c, kugo2p__Favorite__c = favoriteGroups[0].Id),
                    new kugo2p__FavoriteMember__c(kugo2p__Product__c = APDs[1].kugo2p__ReferenceProduct__c, kugo2p__Favorite__c = favoriteGroups[0].Id)
                };

                insert favoriteGroupMembers;
            }

            return favoriteGroupMembers;
        }
        private set;
    }
    
    public static list<kugo2p__FavoriteShare__c> FavoriteShares {
        get {
            if (favoriteShares == null) {
                FavoriteShares = new List<kugo2p__FavoriteShare__c> {
                    new kugo2p__FavoriteShare__c(kugo2p__Favorite__c = favoriteGroups[0].Id, kugo2p__User__c = UserInfo.getUserId())
                };

                insert FavoriteShares;
            }

            return FavoriteShares;
        }
        private set;
    }

    public static kugo2p__Settings__c PaymentSettings {
        get {
            if (PaymentSettings == null) {
                PaymentSettings = new kugo2p__Settings__c(Name = 'Test Payment Settings', kugo2p__KugamonSetting__c = Settings.Id, kugo2p__Gateway_Simulation_Mode__c = true, kugo2p__Admin_User__c = UserInfo.getUserId());
                insert PaymentSettings;
            }
            return PaymentSettings;
        }
        private set;
    }

    public static kugo2p__Processor_Connection__c ProcessorConnection {
        get {
            if (ProcessorConnection == null) {
                ProcessorConnection = new kugo2p__Processor_Connection__c(Name = 'Test Processor Connection', kugo2p__Account_Type__c='Website Payments Pro', kugo2p__PaymentConnect_Setup__c = PaymentSettings.Id, 
                                                                    kugo2p__Default_Connection__c = true, kugo2p__Assigned_To_Terminal__c = true, kugo2p__Processor_Id__c = 'PayPal',
                                                                    kugo2p__Enabled_Card_Types__c='Visa; Mastercard; Amex; Discover', kugo2p__Site_Checkout__c='Both', kugo2p__PDF_Checkout__c='Native', 
                                                                    kugo2p__Tokenized_Card_Service_Enabled__c=true, kugo2p__Test_Mode__c=true,
                                                                    kugo2p__Notification_Relay_Method__c='Visualforce', kugo2p__Relay_Id__c='kugo2p__PayPalRelay', 
                                                                    kugo2p__Relay_Script__c='https://example.salesforce.com/kugo2p__PayPalRelay');
                insert ProcessorConnection;
            }
            return ProcessorConnection;
        }
        private set;
    }                   
}
