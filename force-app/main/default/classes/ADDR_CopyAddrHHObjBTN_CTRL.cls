/*
    Copyright (c) 2011, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2011 (2.3)
* @group Address Management
* @description The controller for the VF page invoked by using the address copy button.
*   This is a simple utility for transferring a contact address to a household
*   or pushing a household address out to its member contacts
*   NOTE: This is only supported for Household__c objects.
*   NOTE: For Household Accounts, the new Address__c object and its associated features provide this functionality.
*/
public with sharing class ADDR_CopyAddrHHObjBTN_CTRL {

    /*******************************************************************************************************
    * @description the source object to copy address fields from
    */
    private SObject obj;

    /*******************************************************************************************************
    * @description the result message (success or errors)
    */
    public String resulttext{get; set;}

    /*******************************************************************************************************
    * @description the URL to return to after running.
    */
    public String returnurl{get; set;}

    /*******************************************************************************************************
    * @description the type of source object (Contact, npo02__Household__c)
    */
    public String strSrcObject { get; set; }

    /*******************************************************************************************************
    * @description whether to redirect on success, or stay on the page for errors.
    */
    public Boolean redirectPage { get; set; }

    /*******************************************************************************************************
    * @description true when the user has permissions required to copy the address
    */
    public Boolean canCopyAddress {
        get {
            if (canCopyAddress == null) {
                canCopyAddress = hasPermissions();
            }

            return canCopyAddress;
        }
        private set;
    }

    /*******************************************************************************************************
    * @description Permissions class used to determine if the running user has permissions
    */
    @TestVisible
    private UTIL_Permissions perms {
        get {
            if (perms == null) {
                perms = new UTIL_Permissions();
            }

            return perms;
        }
        set;
    }

    /*******************************************************************************************************
    * @description HH address fields by Contact Address fields
    */
    private static final Map<SObjectField, SObjectField> HH_BY_CONTACT_ADDR_FIELDS =
        new Map<SObjectField, SObjectField>{
            Contact.MailingStreet => npo02__Household__c.npo02__MailingStreet__c,
            Contact.MailingCity => npo02__Household__c.npo02__MailingCity__c,
            Contact.MailingState => npo02__Household__c.npo02__MailingState__c,
            Contact.MailingPostalCode => npo02__Household__c.npo02__MailingPostalCode__c,
            Contact.MailingCountry => npo02__Household__c.npo02__MailingCountry__c
        };

    /***
    * @description Address fields
    */
    private static final Set<SObjectField> ADDRESS_FIELDS = new Set<SObjectField>{
        Address__c.MailingStreet__c,
        Address__c.MailingCity__c,
        Address__c.MailingState__c,
        Address__c.MailingPostalCode__c,
        Address__c.MailingCountry__c
    };

    /*******************************************************************************************************
    * @description Constructor for the class
    */
    public ADDR_CopyAddrHHObjBTN_CTRL(){

        obj = null;
        strSrcObject = null;
        returnurl = null;
        resulttext = null;
        redirectPage = false;
        Id id = ApexPages.currentPage().getParameters().get('id');

        if (id != null) {
            if (UTIL_Describe.isObjectIdThisType(id, 'Contact')) {
                strSrcObject = 'Contact';
                obj = [select id from Contact where id = :id];
            } else if (UTIL_Describe.isObjectIdThisType(id, 'npo02__Household__c')) {
                strSrcObject = 'npo02__Household__c';
                obj = [select id from npo02__Household__c where id = :id];
            }
            if (obj != null) {
                PageReference pageRef = new PageReference('/' + obj.id);
                returnurl = pageref.getUrl();
            }
        }
    }

    /*******************************************************************************************************
    * @description Action method called when the user clicks on the copy button.
    * @return PageReference - null
    */
    public PageReference buttonClick(){
    * then permissions on the Address SObject are not verified.
    * @return Boolean
    */
    private Boolean hasPermissionsOnAddress() {
        if (UTIL_CustomSettingsFacade.getContactsSettings().Household_Account_Addresses_Disabled__c) {
            //permissions on Address are not required
            //when Address record is not expected to be created
            return true;
        }

        SObjectType objType = Address__c.sObjectType;
        //The user needs Create and Edit permissions on the Address SObject
        //as well as read and editable permission on Mailing address fields on Address SObject
        if (!perms.canCreate(objType, ADDRESS_FIELDS)
            || !perms.canUpdate(objType)
        ) {
            return false;
        }

        return true;
    }

}
