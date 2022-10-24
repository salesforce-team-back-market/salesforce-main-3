public class ManageRecordtype{

    public static Id ManageRecordtype(string RTName,String sobjecttype){
            Id RTID = null;
            if(ManageRT__c.getInstance(RTName+';'+sobjecttype)!=null)
                RTID = ManageRT__c.getInstance(RTName+';'+sobjecttype).RT__c;
                
            return RTID;
         
    }
}