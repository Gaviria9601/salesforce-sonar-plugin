/**
 * Nombre Clase : LeadServiceLayer
 * Objeto relacionado : Lead
 * Creado Por: Mauricio Ruiz
 * Descripción: Clase de servicio para lógicas relacionadas al objeto lead
 */
public with sharing class LeadServiceLayer {
    //private static final string COMMERCIAL_OPP_RT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('bc_CommercialOpportunities').getRecordTypeId();

    public static void setOwnerIdOnLead(List<Lead> leads) {
        list<Id> accountIds = new list<Id>();
        for(Lead objLead:leads){
            if(objLead.FinServ__RelatedAccount__c != null){
                accountIds.add(objLead.FinServ__RelatedAccount__c);
            }
        }
        if(!accountIds.isEmpty()){
            //map<Id,Account> relatedAccounts = new map<Id,Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]);
            for(Lead objLead:leads){
                if(relatedAccounts.get(objLead.FinServ__RelatedAccount__c) != null){
                    objLead.OwnerId = relatedAccounts.get(objLead.FinServ__RelatedAccount__c).OwnerId;
                    objLead.bc_managementUserCode__c = relatedAccounts.get(objLead.FinServ__RelatedAccount__c).OwnerId;
                }
            }
        }

    }

    public static void processCommercialOpp(list<ResponseCommercialOpportunities.GeneralInformation> listOfOpps,String accountId, String documentId, String documentType) {
        Map<String, Lead> commercialOppMap = new Map<String, Lead>();
        List<bc_preapprovedItem__c> itemsToSave = new list<bc_preapprovedItem__c>();
        for (Lead l : [ select Id,bc_actionCode__c,bc_productCode__c,FinServ__RelatedAccount__r.bc_documentId__c,
                        FinServ__RelatedAccount__r.bc_documentTypeSTOC__c
                        from Lead where FinServ__RelatedAccount__c =: accountId]) {
            string key = l.FinServ__RelatedAccount__r.bc_documentTypeSTOC__c+''+l.FinServ__RelatedAccount__r.bc_documentId__c+''+l.bc_actionCode__c+''+l.bc_productCode__c;
            commercialOppMap.put(key, l);
        }
        for(ResponseCommercialOpportunities.GeneralInformation opp:listOfOpps){
            String actionCode = String.valueOf(opp.actionCode);
            String productCode =  String.valueOf(opp.productCode);
            String keyMapExternalId = documentType+''+documentId+''+actionCode+''+productCode;
            Lead incomingOpp;
            if (commercialOppMap.containsKey(keyMapExternalId)){
                incomingOpp = commercialOppMap.get(keyMapExternalId);
            } else {
                incomingOpp = new Lead(bc_actionCode__c = actionCode, LastName = opp.productDetailDescription,
                                       bc_productCode__c = productCode, bc_productDetailDescription__c = opp.productDetailDescription);
                commercialOppMap.put(keyMapExternalId, incomingOpp);
            }
            incomingOpp.recordTypeId = COMMERCIAL_OPP_RT;
            incomingOpp.bc_externalId__c = keyMapExternalId;
            incomingOpp.FinServ__RelatedAccount__c = accountId;
            incomingOpp.bc_opportunityId__c = opp.opportunityId;
            incomingOpp.bc_needCode__c = String.valueOf(opp.needCode);
            incomingOpp.bc_actionDescription__c = opp.actionDescription;
            incomingOpp.bc_reason__c = opp.reason;
            incomingOpp.bc_benefit__c = opp.benefit;
            incomingOpp.bc_riskGroupName__c = opp.riskGroupName;
            incomingOpp.bc_categoryCode__c = opp.categoryCode;
            incomingOpp.bc_categoryDescription__c = opp.categoryDescription;
            incomingOpp.bc_expirationDate__c = opp.preapprovedDetail != null ? Date.valueOf(opp.preapprovedDetail?.expirationDate):null;
            incomingOpp.bc_minimumTerm__c = opp.preapprovedDetail?.minimumTerm;
            incomingOpp.bc_maximumTerm__c = opp.preapprovedDetail?.maximumTerm;
            incomingOpp.bc_creditCardMaximumCapacity__c = opp.generalConditions?.creditCardMaximumCapacity;
            incomingOpp.bc_creditCardBenefit__c = opp.generalConditions?.creditCardBenefit;
            incomingOpp.bc_overdraftMaximunCapacity__c = opp.generalConditions?.overdraftMaximunCapacity;
            incomingOpp.bc_freeInvestmentMaximunCapacity__c = opp.generalConditions?.freeInvestmentMaximunCapacity;
            incomingOpp.bc_repaymentLoanNumber__c = opp.generalConditions?.repaymentLoanNumber;
            incomingOpp.bc_agreementCode__c = opp.payrollDeductionConditions?.agreementCode;
            incomingOpp.bc_alternativeMinimumTerm__c = opp.payrollDeductionConditions?.alternativeMinimumTerm;
            incomingOpp.bc_alternativeMaximumTerm__c = opp.payrollDeductionConditions?.alternativeMaximumTerm;
            incomingOpp.bc_entity__c = opp.purchasePortfolioConditions?.entity;
            incomingOpp.bc_currentBalance__c = opp.purchasePortfolioConditions?.currentBalance;
            incomingOpp.bc_initialValue__c = opp.purchasePortfolioConditions?.initialValue;
            incomingOpp.bc_currentPaymentFee__c = opp.purchasePortfolioConditions?.currentPaymentFee;
            incomingOpp.bc_newPaymentFee__c = opp.purchasePortfolioConditions?.newPaymentFee;
            incomingOpp.bc_currentFee__c = opp.purchasePortfolioConditions?.currentFee;
            incomingOpp.bc_newFee__c = opp.purchasePortfolioConditions?.newFee;
            incomingOpp.bc_entity__c = opp.purchasePortfolioConditions?.bankName;
            incomingOpp.bc_loanNumber__c = opp.purchasePortfolioConditions?.loanNumber;
            incomingOpp.bc_estimatedFeeBank__c = opp.purchasePortfolioConditions?.estimatedFeeBank;
            incomingOpp.bc_missingPayments__c = opp.purchasePortfolioConditions?.missingPayments;
            incomingOpp.bc_arrearsDays__c = opp.purchasePortfolioConditions?.arrearsDays;
            incomingOpp.bc_expiredMonthFee__c = opp.mortgageConditions?.expiredMonthFee;
            incomingOpp.bc_annualEffectiveFee__c = opp.mortgageConditions?.annualEffectiveFee;
            incomingOpp.bc_leasingFee__c = opp.mortgageConditions?.leasingFee;
            incomingOpp.bc_annualEffectiveUvr__c = opp.mortgageConditions?.annualEffectiveUvr;
            incomingOpp.bc_expiredMonthUvr__c = opp.mortgageConditions?.expiredMonthUvr;
            incomingOpp.bc_depositAfterAdjustedSpending__c = opp.mortgageConditions?.depositAfterAdjustedSpending;
            //Inicia lastManagement
            incomingOpp.bc_stateCode__c = opp.lastManagement != null ? String.valueOf(opp.lastManagement?.stateCode):'';
            incomingOpp.bc_stateName__c	= opp.lastManagement?.stateName;
            incomingOpp.bc_subStateCode__c = opp.lastManagement != null ? String.valueOf(opp.lastManagement?.subStateCode):'';
            incomingOpp.bc_subStateName__c	= opp.lastManagement?.subStateName;
            incomingOpp.bc_visitDate__c = opp.lastManagement != null ? Date.valueOf(opp.lastManagement?.visitDate):null;
            incomingOpp.bc_managementDate__c = opp.lastManagement != null ? Date.valueOf(opp.lastManagement?.managementDate):null;
            incomingOpp.bc_contactTypeCode__c = opp.lastManagement != null ? String.valueOf(opp.lastManagement?.contactTypeCode):'';
            incomingOpp.bc_contactTypeName__c = opp.lastManagement?.contactTypeName;
            incomingOpp.bc_contactPurposeCode__c = opp.lastManagement != null ? String.valueOf(opp.lastManagement?.contactPurposeCode):'';
            incomingOpp.bc_contactPurposeName__c = opp.lastManagement?.contactPurposeName;
            incomingOpp.bc_businessValue__c = opp.lastManagement?.businessValue;
            incomingOpp.bc_currencyCode__c = opp.lastManagement != null ? String.valueOf(opp.lastManagement?.currencyCode):'';
            incomingOpp.bc_currencyName__c = opp.lastManagement?.currencyName;
            incomingOpp.bc_nextContactDate__c = opp.lastManagement != null && opp.lastManagement.nextContactDate != null ? Date.valueOf(opp.lastManagement.nextContactDate):null;
            incomingOpp.bc_preapprovedChangeFlag__c = opp.lastManagement != null && opp.lastManagement.preapprovedChangeFlag != null ? opp.lastManagement.preapprovedChangeFlag:false;
            incomingOpp.bc_globalQuoteFlag__c = opp.lastManagement != null && opp.lastManagement.globalQuoteFlag != null ? opp.lastManagement.globalQuoteFlag:false;
            incomingOpp.bc_contactChannelCode__c = opp.lastManagement != null ? String.valueOf(opp.lastManagement?.contactChannelCode):'';
            incomingOpp.bc_contactChannelName__c = opp.lastManagement?.contactChannelName;
            incomingOpp.bc_observations__c = opp.lastManagement?.observations;
            if(opp.lastManagement != null && opp.lastManagement.preapprovedChangeChoices != null){
                for(ResponseCommercialOpportunities.PreapprovedChangeChoices child:opp.lastManagement.preapprovedChangeChoices){
                    bc_preapprovedItem__c newItem = new bc_preapprovedItem__c();
                    newItem.bc_productChangeByProduct__c = String.valueOf(child.productCode);
                    newItem.bc_businessValue__c = child.businessValue;
                    newItem.bc_lead__r = new Lead(bc_externalId__c = keyMapExternalId);
                    if(Test.isRunningTest()){
                        Integer externalRandomId = Integer.valueof((Math.random() * 1000));
                        newItem.bc_externalId__c = keyMapExternalId+''+externalRandomId;
                    }else{
                        newItem.bc_externalId__c = keyMapExternalId+''+child.productCode;
                    }
                    itemsToSave.add(newItem);
                }
            }
        }
        upsert commercialOppMap.values();
        upsert itemsToSave bc_externalId__c;
    }
}