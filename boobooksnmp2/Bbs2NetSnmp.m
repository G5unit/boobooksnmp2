/*
 Bbs2NetSnmp.m
 
 Boobooksnmp2
 Cocoa based user interface program with a MIB browser and SNMP functionality
 Copyright (C) <2017>  <Faruk Grozdanic>
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 For a copy of the GNU General Public License see
 <http://www.gnu.org/licenses/>.
 
 */
#import "Bbs2NetSnmp.h"

@implementation Bbs2NetSnmpRequest
@end

@implementation Bbs2NetSnmp

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        
        //Load net-snmp
        [self startNetSnmp];

    }
    return self;
}

int bbs2_log_callback(netsnmp_log_handler* logh, int pri, const char *str)
{
    NSDictionary * messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",[NSString stringWithUTF8String:str],@"message", nil];    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:messageDictionary];
    return 1;
}

-(NSString *)getNetSnmpVersion {
    
    return [NSString stringWithUTF8String:netsnmp_get_version()];
}
/* Need more recent snmplib then 5.6.2.1, 5.8 does have these usm_lookup calls */
/*
-(NSArray *)getV3AuthProtocols {
    int authtypescount = 7;
    const char* authtypes[7] = {
        "MD5","SHA-1","SHA-192","SHA-224","SHA-256","SHA-348","SHA-512"
    };
    
    NSArray * supportedTypes = [[NSArray alloc] init];
    for(int i=0;i<authtypescount;i++) {
       if(usm_lookup_auth_type(authtypes[i]) > 0) {
          [ add  authtypes[i]  to array supportedTypes];
       }
    }
    return supportedTypes;
}
 -(NSArray *)getV3PrivProtocols {
 int privprotoscount = 7;
 const char* privprotos[7] = {
    "MD5","SHA-1","SHA-192","SHA-224","SHA-256","SHA-348","SHA-512"
 };
 
 NSArray * supportedProtos = [[NSArray alloc] init];
 for(int i=0;i<privprotoscount;i++) {
    if(usm_lookup_priv_type(privprotos[i]) > 0) {
       [ add  privprotos[i]  to array supportedProtos];
    }
 }
 return supportedProtos;
 }
 */

-(void)startNetSnmp {
    NSString *userAppSupportDirectory;
    NSArray *directoryPath = NSSearchPathForDirectoriesInDomains (NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if ([directoryPath count] > 0)  {
        userAppSupportDirectory = [[directoryPath objectAtIndex:0] stringByAppendingPathComponent:@"Boobooksnmp2"];
    }
    
    // Net-Snmp library settings
    //Save Descriptions; snmp_set_save_descriptions(1);
    netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_SAVE_MIB_DESCRS, 1);
    
    //replace MIB symbols from latest module
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"netsnmpMibReplace"] &&
       [[NSUserDefaults standardUserDefaults] boolForKey:@"netsnmpMibReplace"] == YES) {
        netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_REPLACE, 1);
    } else { netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_REPLACE, 0); }

    //Allow underlines in MIB symbols
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"netsnmpParseLabel"] &&
       [[NSUserDefaults standardUserDefaults] boolForKey:@"netsnmpParseLabel"] == YES) {
        netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_PARSE_LABEL, 1);
    } else { netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_PARSE_LABEL, 0); }

    //Allow the use of -- to terminate comments
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"netsnmpMibComment"] &&
       [[NSUserDefaults standardUserDefaults] boolForKey:@"netsnmpMibComment"] == YES) {
        netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_COMMENT_TERM, 1);
    } else { netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_COMMENT_TERM, 0); }

    //Disable errors when MIB symbols conflict
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"netsnmpMibErrors"] &&
       [[NSUserDefaults standardUserDefaults] boolForKey:@"netsnmpMibErrors"] == YES) {
        netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_ERRORS, 0);
    } else { netsnmp_ds_set_boolean(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_ERRORS, 1); }
 
    //Enable warnings when MIB symbols conflict
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"netsnmpMibWarnings"]) {
        NSInteger wvalue = [[NSUserDefaults standardUserDefaults] integerForKey:@"netsnmpMibWarnings"];
        netsnmp_ds_set_int(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_WARNINGS, (int)wvalue);
    } else { netsnmp_ds_set_int(NETSNMP_DS_LIBRARY_ID,NETSNMP_DS_LIB_MIB_WARNINGS,0); }
    

    //Clear net-Snmp default paths for MIBs
    netsnmp_set_mib_directory("");
    
    
    //Configure error logging
    //Register Default Null loghandler; without this netsnmp dumps to stdout
    netsnmp_register_loghandler(NETSNMP_LOGHANDLER_NONE, LOG_EMERG);
    //Setup Bbs2 logHandler
    NSUInteger loglevel = 3;
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSnmpLogLevel"] ||
       [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSnmpLogLevel"] == 0) {
            loglevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSnmpLogLevel"];
    }
    _bbs2logHandler = netsnmp_register_loghandler(NETSNMP_LOGHANDLER_CALLBACK, (int)loglevel);
    if (!_bbs2logHandler) {
        NSDictionary * messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",@"[Bbs2] Could not create netsnnmp log handler.",@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:messageDictionary];
    }
    else {
        _bbs2logHandler->handler = bbs2_log_callback;
    }
    
    // Init netsnmp mib
    netsnmp_init_mib_internals();
    // Load files, only ones that user has check for loading
    NSArray * filesToLoad = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BBS2SavedMibLibrary"]];
    if(!filesToLoad) { filesToLoad = [[NSArray alloc] init]; }
    for(id mibfile in filesToLoad) {
        if([[mibfile objectForKey:@"loadFile"] integerValue] > 0) {
            read_mib([[userAppSupportDirectory stringByAppendingPathComponent:[mibfile objectForKey:@"mibFileName"]] UTF8String]);
        }
    }
    
    //Adopt orphans; calling read_all_mib() at this point will acheive the same end result as adopt_orphans()
//    adopt_orphans();
    netsnmp_init_mib();
     
    // Set root node
    _rootNode = get_tree_head();
}

-(void)stopNetSnmp {
    //Release rootNode
    _rootNode = nil;
    //Stop net-snmp
    netsnmp_disable_this_loghandler(_bbs2logHandler);
    netsnmp_remove_loghandler(_bbs2logHandler);
    _bbs2logHandler = nil;
    unload_all_mibs();
    shutdown_mib();
    
}

-(void)reInitNetSnmp {
    [self stopNetSnmp];
    [self startNetSnmp];
}


-(NSArray *)searchMibTree:(NSString *)searchString {
    NSMutableArray * oidSearchResults = [[NSMutableArray alloc] init];
    if(searchString) {
        clear_tree_flags(_rootNode);
        
        int searchResultCount = 1;
        u_int somematchsht = 0;
        while (searchResultCount < 512) { /* limit searches returned to 512; popup menu with search results gets to be too big and UI suffers */
            struct tree    *tp = find_best_tree_node([searchString UTF8String], _rootNode, &somematchsht);
            
            if (!tp) {
                break;
            }
            if (tp->label != nil) {
                [oidSearchResults addObject:[NSString stringWithUTF8String: tp->label]];
            }
            searchResultCount++;
        }
        return oidSearchResults;
    }
    return nil;
}

-(NSString *)populateSnmpAuthentication:(Bbs2NetSnmpRequest *)requestData forSession:(struct snmp_session *) bbss {
    // Set the default SNMP version number
    bbss->version = SNMP_VERSION_2c;
    if([[[requestData agent] objectForKey:@"Version"] intValue] == 3) {
        bbss->version = SNMP_VERSION_3;
        
        if(![[[requestData agent] objectForKey:@"v3Username"] isEqualToString:@""]) {
            bbss->securityName = (char *)[[[requestData agent] objectForKey:@"v3Username"] UTF8String];
            bbss->securityNameLen = strlen(bbss->securityName);
        }
        if(![[[requestData agent] objectForKey:@"v3Context"] isEqualToString:@""]) {
            bbss->contextName = (char *)[[[requestData agent] objectForKey:@"v3Context"] UTF8String];
            bbss->contextNameLen = strlen(bbss->contextName);
        }
        
        //Get v3SecutiryLevel; values are 0: NoAuth, 1: SNMP_SEC_LEVEL_AUTHNOPRIV, 2:SNMP_SEC_LEVEL_AUTHPRIV
        NSNumber * v3Authmethod = [[requestData agent] objectForKey:@"v3Authmethod"];
        bbss->securityLevel = SNMP_SEC_LEVEL_NOAUTH;
        //If Authentication is used populate needed values
        if([v3Authmethod intValue] > 0) {
            bbss->securityLevel = SNMP_SEC_LEVEL_AUTHNOPRIV;
            switch ([[[requestData agent] objectForKey:@"v3Authproto"] intValue]) {
                case 1:
                    bbss->securityAuthProto = usmHMACSHA1AuthProtocol;
                    bbss->securityAuthProtoLen = sizeof(usmHMACSHA1AuthProtocol)/sizeof(oid);
                    break;
                default:
                    bbss->securityAuthProto = usmHMACMD5AuthProtocol;
                    bbss->securityAuthProtoLen = sizeof(usmHMACMD5AuthProtocol)/sizeof(oid);
                    break;
            }
            bbss->securityAuthKeyLen = USM_AUTH_KU_LEN;
            char * v3AuthPhrase = (char *)[[[requestData agent] objectForKey:@"v3Authphrase"] UTF8String];
            if (generate_Ku(bbss->securityAuthProto,
                            (u_int)bbss->securityAuthProtoLen,
                            (u_char *) v3AuthPhrase, strlen(v3AuthPhrase),
                            bbss->securityAuthKey,
                            &bbss->securityAuthKeyLen) != SNMPERR_SUCCESS) {
                return @"[BBS2] Could not generate HEXKEY from Authentication phrase";
            }
            
        }
        //If Privacy (encryption) is used populate needed values
        if([v3Authmethod intValue] == 2) {
            bbss->securityLevel = SNMP_SEC_LEVEL_AUTHPRIV;
            switch ([[[requestData agent] objectForKey:@"v3Privproto"] intValue]) {
                case 1:
                    bbss->securityPrivProto = usmAESPrivProtocol;
                    bbss->securityPrivProtoLen = USM_PRIV_PROTO_AES_LEN;
                    break;
                default:
                    bbss->securityPrivProto = usmDESPrivProtocol;
                    bbss->securityPrivProtoLen = USM_PRIV_PROTO_DES_LEN;
                    break;
            }

            bbss->securityPrivKeyLen = USM_PRIV_KU_LEN;
            char * v3Privphrase = (char *)[[[requestData agent] objectForKey:@"v3Privphrase"] UTF8String];
            if (generate_Ku(bbss->securityAuthProto,
                            (u_int)bbss->securityAuthProtoLen,
                            (u_char *) v3Privphrase, strlen(v3Privphrase),
                            bbss->securityPrivKey,
                            &bbss->securityPrivKeyLen) != SNMPERR_SUCCESS) {
                return @"[BBS2] Could not generate HEXKEY from Private phrase";
            }
        }
    } else {
        //If not V3 then it is SNMPV1 or V2c
        if([[[requestData agent] objectForKey:@"Version"] intValue] == 1) {
            bbss->version = SNMP_VERSION_1;
        }
        // set the SNMPv1/2c community name used for authentication
        // If doing SNMP SET then populate write string
        if((int)[requestData requestType] == 3) {
            bbss->community = (u_char *)[[[requestData agent] objectForKey:@"Writecommunity"] UTF8String];
        } else {
            bbss->community = (u_char *)[[[requestData agent] objectForKey:@"Readcommunity"] UTF8String];
        }
        bbss->community_len = strlen((const char *)bbss->community);
    }
    
    return nil;
}
-(NSString *)validateRequestData:(Bbs2NetSnmpRequest *)requestData {
    // Hostname (or IP address) should be present
    if([[requestData.agent objectForKey:@"Hostname"] isEqualToString:@""]) { return @"[BBS2] Agent hostname is needed."; }

    //For set request check that setValue is present and not blank
    if([requestData requestType] == 3 && (![requestData.oid objectForKey:@"SetValue"] || [[requestData.oid objectForKey:@"SetValue"] isEqualToString:@""])) {
        return @"[BBS2] Set value needed for SNMP set request.";
    }
    
    // For SNMP V1 & V2 if read and write string are not present
    if([[[requestData agent] objectForKey:@"Version"] intValue] < 3) {
        if(requestData.requestType == 3 && [[[requestData agent] objectForKey:@"Writecommunity"] isEqualToString:@""]) {
            return @"[BBS2] Write community string is needed for SNMP set request.";
        }
        if(requestData.requestType != 3 && [[[requestData agent] objectForKey:@"Readcommunity"] isEqualToString:@""]) {
            return @"[BBS2] Read community string is needed for SNMP get requests.";
        }
        return nil;
    }

    // For SNMP V3 make sure that Auth && Encryption keys are present!!!
    //    There are no defaults for SNMPV3 Auth & Encrypt so throw an error if not present.
    NSNumber * v3Authmethod = [[requestData agent] objectForKey:@"v3Authmethod"];
    if([v3Authmethod intValue] < 0) { return @"[BBS2] SNMPv3 Method selection is not specified"; }
    if([v3Authmethod intValue] > 0) {
        if([[[requestData agent] objectForKey:@"v3Authproto"] intValue] < 0) { return @"[BBS2] SNMPv3 Authentication protocol is not specified"; }
        if([[requestData.agent objectForKey:@"v3Authphrase"] isEqualToString:@""]) { return @"[BBS2] Authentication passphrase needed."; }
    }
    if([v3Authmethod intValue] == 2) {
        if([[[requestData agent] objectForKey:@"v3Privproto"] intValue] < 0) { return @"[BBS2] SNMPv3 Encryption (privacy) protocol is not specified"; }
        if([[requestData.agent objectForKey:@"v3Privphrase"] isEqualToString:@""]) { return @"[BBS2] Encryption (privacy) passphrase needed."; }
    }

    return nil;
}

- (NSString *)getPDUerrstring:(long)someErr
{
    switch (someErr) {
        case 0:
            return @"No Error";
            break;
        case 1:
            return @"Response message is too large";
            break;
        case 2:
            return @"There is no such variable name in this MIB";
            break;
        case 3:
            return @"Invalid Value, possibly wrong type or length";
            break;
        case 4:
            return @"Read Only, No access to use the specified SNMP Object";
            break;
        case 5:
            return @"A general failure occured";
            break;
        case 6:
            return @"No Access";
            break;
        case 7:
            return @"Wrong Type, Agent expects different datatype for set";
            break;
        case 8:
            return @"Set value too large, not what the agent expects";
            break;
        case 9:
            return @"Wrong Encoding";
            break;
        case 10:
            return @"Wrong Value, could be illegal or unsupported";
            break;
        case 11:
            return @"No Creation Object could be created";
            break;
        case 12:
            return @"Inconsistent Value, illegal or unsupported";
            break;
        case 13:
            return @"Resource Unavailable, agent out of resources";
            break;
        case 14:
            return @"Commit Failed";
            break;
        case 15:
            return @"Undo Failed";
            break;
        case 16:
            return @"Authorization Error, access denied";
            break;
        case 17:
            return @"Not Writable, object does not support modification";
            break;
        case 18:
            return @"Inconsistent Name, object can not currently be created";
            break;
        default:
            return @"Unknown Error";
            break;
            
    }
    
}

- (NSString *)oidToName:(const oid *)objectid withObjectLength:(size_t)objectidLength  {
    u_char *nameCharPtr = NULL;
    NSString * nameString;
    size_t nameCharPtrLength = 256, outputLength = 0;
    if ((nameCharPtr = (u_char *) calloc(nameCharPtrLength, 1)) != NULL && sprint_realloc_objid(&nameCharPtr, &nameCharPtrLength, &outputLength, 0, objectid, objectidLength)) {
        nameString = [NSString stringWithFormat:@"%s",(char *)nameCharPtr];
        SNMP_FREE(nameCharPtr);
        //        NSArray * myTmpArray = [tmpDBGChar componentsSeparatedByString:@"::"];
        return [[nameString componentsSeparatedByString:@"::"] lastObject];
    } else {
        return @"";
    }
}

- (NSString *)variableOidToName:(const netsnmp_variable_list *)variable withObject:(const oid *)objectid withObjectLength:(size_t)objectidLength  {
    u_char *nameCharPtr = NULL;
    NSString * nameString;
    size_t nameCharPtrLength = 256, outputLength = 0;
    if (variable->type == SNMP_NOSUCHINSTANCE) { return @"NO SUCH INSTANCE"; }
    if ((nameCharPtr = (u_char *) calloc(nameCharPtrLength, 1)) != NULL && sprint_realloc_value(&nameCharPtr, &nameCharPtrLength, &outputLength, 0, objectid, objectidLength,variable)) {
        nameString = [NSString stringWithFormat:@"%s",(char *)nameCharPtr];
        SNMP_FREE(nameCharPtr);
        //        NSArray * myTmpArray = [tmpDBGChar componentsSeparatedByString:@"::"];
        return [[nameString componentsSeparatedByString:@"::"] lastObject];
    } else {
        return @"";
    }
}

-(void)addResultsToView:(NSMutableDictionary *)result {
    [result setObject:[NSDate date] forKey:@"timestamp"];
    [_tabView performSelectorOnMainThread:@selector(addQueryResult:)
                            withObject:[NSArray arrayWithObject:[result mutableCopy]]
                            waitUntilDone:NO];
 
}

/* Handles following SNMP operations: GET, GETNEXT, SET */
-(NSString *)snmpGetRequest:(Bbs2NetSnmpRequest *)requestData {

    void * bbss;
    netsnmp_session boobookSnmpSession, *bbssp;
    netsnmp_pdu *boobookRequestPdu = nil;
    netsnmp_pdu *boobookResponsePdu;
    
    oid session_snmpOID[MAX_OID_LEN];
    size_t session_snmpOID_len = MAX_OID_LEN;
    int snmpStatus = -1;
    int addVarResult;
    struct variable_list *snmpVars;

    NSString * returnCode = nil;
    
    // Setup Dict that holds result; time, agent, object, result, action, setValue
    NSMutableDictionary * resultsDict = [[NSMutableDictionary alloc] init];
    [resultsDict setObject:[requestData.agent objectForKey:@"Name"] forKey:@"agent"];
    [resultsDict setObject:[requestData.oid objectForKey:@"OID"] forKey:@"snmpObject"];
    [resultsDict setObject:@"[Bbs2]" forKey:@"resultObj"];
    [resultsDict setObject:@"" forKey:@"setValue"];
    [resultsDict setObject:@"" forKey:@"action"];

    if([requestData requestType] == 1) {
        [resultsDict setObject:@"SNMP GET" forKey:@"action"];
    }else if([requestData requestType] == 2) {
        [resultsDict setObject:@"SNMP GETNEXT" forKey:@"action"];
    }else if([requestData requestType] == 3) {
        [resultsDict setObject:@"SNMP SET" forKey:@"action"];
    } else {
        [resultsDict setObject:@"Unknown request Type received" forKey:@"action"];
    }
    
    if([requestData requestType] == 3 && [requestData.oid objectForKey:@"SetValue"]) {
        [resultsDict setObject:[requestData.oid objectForKey:@"SetValue"] forKey:@"setValue"];
    }

    //Validate Request Data
    returnCode = [self validateRequestData:requestData];
    if(returnCode) {
        [resultsDict setObject:returnCode forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        return returnCode;
    }

    // Create the pdu depending on request type
    NSString * createPDUstatus;
    read_objid((char *)[[[requestData oid] objectForKey:@"OID"] UTF8String], session_snmpOID, &session_snmpOID_len);
    // !! Is there a way to check if read_objid was successful ?
    if([requestData requestType] == 1) {
        boobookRequestPdu = snmp_pdu_create(SNMP_MSG_GET);
        snmp_add_null_var(boobookRequestPdu, session_snmpOID, session_snmpOID_len);
    }else if([requestData requestType] == 2) {
        boobookRequestPdu = snmp_pdu_create(SNMP_MSG_GETNEXT);
        snmp_add_null_var(boobookRequestPdu, session_snmpOID, session_snmpOID_len);
    }else if([requestData requestType] == 3) {
        boobookRequestPdu = snmp_pdu_create(SNMP_MSG_SET);
        addVarResult = snmp_add_var(boobookRequestPdu, session_snmpOID, session_snmpOID_len, '=', [[requestData.oid objectForKey:@"SetValue"] UTF8String]);
        if (addVarResult > 0) {
            createPDUstatus = [NSString stringWithFormat:@"%@",[self getPDUerrstring:addVarResult]];
        } else if (addVarResult < 0) {
            createPDUstatus = @"Object has no Access permissions";
        }
    } else {
        createPDUstatus = @"Request type received not valid";
    }
    if(createPDUstatus) {
        [resultsDict setObject:createPDUstatus forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        return createPDUstatus;
    }
    // Init Session
    NSString * sessionName = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    init_snmp([sessionName UTF8String]); // without this I get Engine ID error for v3
    snmp_sess_init( &boobookSnmpSession );
    // Here check for return error from snmp_sess_init() if any and raise Error
    
    // Set name of remote host; remote port (separated by ":") is part of it that net-snmnp lib takes care of
    boobookSnmpSession.peername = (char *)[[[requestData agent] objectForKey:@"Hostname"] UTF8String] ;

    // Configure Retries & Timeout values
    boobookSnmpSession.retries = (int)[[[requestData agent] objectForKey:@"Retries"] integerValue];
    /* Timeout is in microseconds */
    boobookSnmpSession.timeout = ([[[requestData agent] objectForKey:@"Timeout"] integerValue] * 1000000);

    //Populate SNMP Authentication data
    returnCode = [self populateSnmpAuthentication:requestData forSession:&boobookSnmpSession];
    if(returnCode) {
        // Clear/release boobookSnmpSession snmp_session structure!!!
        return returnCode;
    } // OR populate query array with result as Error: ...
 
    
    // Establish the session
    bbss = snmp_sess_open(&boobookSnmpSession);
    bbssp = snmp_sess_session(bbss);

    if (!bbss) {
        returnCode = [NSString stringWithFormat:@"Could not open snmp session to host: %@",[[requestData agent] objectForKey:@"Name"]];
        [resultsDict setValue:returnCode forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
//        snmp_sess_perror("snmpOp", &boobookSnmpSession);
        return returnCode;
    }
    
    // Send the PDU request
    snmpStatus = snmp_sess_synch_response(bbss, boobookRequestPdu, &boobookResponsePdu);

    // Check for errors
    if (snmpStatus == STAT_TIMEOUT) {
        returnCode = [NSString stringWithFormat:@"Timeout getting response from host: %@", [requestData.agent objectForKey:@"Hostname"]];
        [resultsDict setObject:returnCode forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        
        snmp_sess_close(bbss);
        return returnCode;
    }
    if (snmpStatus != STAT_SUCCESS) {
        char           *err;
        snmp_sess_error(bbss, NULL, NULL, &err);
        returnCode = [NSString stringWithFormat:@"SNMP Request not successful: %s", err];
        [resultsDict setObject:returnCode forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        
        SNMP_FREE(err);
        snmp_sess_close(bbss);
        return returnCode;
    }
    if(!boobookResponsePdu) {
        [resultsDict setObject:[NSString stringWithFormat:@"Request was good, yet responsePDU was not received!"] forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        returnCode = [NSString stringWithFormat:@"[BBS2] Request was good, yet responsePDU was not received!"];

        snmp_sess_close(bbss);
        return returnCode;
    }
    if(boobookResponsePdu && boobookResponsePdu->errstat != SNMP_ERR_NOERROR) {
        [resultsDict setObject:[NSString stringWithFormat:@"%@",[self getPDUerrstring:boobookResponsePdu->errstat]] forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        returnCode = [NSString stringWithFormat:@"[BBS2] %@",[self getPDUerrstring:boobookResponsePdu->errstat]];

        snmp_sess_close(bbss);
        snmp_free_pdu(boobookResponsePdu);
        return returnCode;
    }
    
    //For SNMP SET this means op was successful, populate return message to indicate such
    if((int)[requestData requestType] == 3) {
        [resultsDict setObject:[NSString stringWithFormat:@"SNMP Set completed with success."] forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        
        if (boobookResponsePdu ) { snmp_free_pdu(boobookResponsePdu); }
        snmp_sess_close(bbss);
        return @"[BBS2] SNMP Set completed with success.";
        
    }
    //For SNMP GET & GETNEXT responsePdu has the data we need; populate display array
    for(snmpVars = boobookResponsePdu->variables; snmpVars; snmpVars = snmpVars->next_variable) {
        NSString * objstr = [self oidToName:snmpVars->name withObjectLength:snmpVars->name_length];
        NSString * resultstr = [self variableOidToName:snmpVars withObject:snmpVars->name withObjectLength:snmpVars->name_length];
//        NSString * resultsString = [NSString stringWithFormat:@"Object name: %@  value: %@",objstr,resultstr];
        [resultsDict setObject:objstr forKey:@"resultObj"];
        [resultsDict setObject:resultstr forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
    }

    //Cleanup
    if (boobookResponsePdu ) { snmp_free_pdu(boobookResponsePdu); }
    snmp_sess_close(bbss);
    
    return returnCode;
    
}
-(NSString *)snmpWalkRequest:(Bbs2NetSnmpRequest *)requestData {
    void * bbss;
    netsnmp_session boobookSnmpSession, *bbssp;
    netsnmp_pdu *boobookRequestPdu = nil;
    netsnmp_pdu *boobookResponsePdu, *freePdu;
    
    oid session_snmpOID[MAX_OID_LEN];
    size_t session_snmpOID_len = MAX_OID_LEN;
    int snmpStatus = -1;
    struct variable_list *snmpVars;
    
    NSString * returnCode = nil;
    
    // Setup Dict that holds result; time, agent, object, result, action. setValue
    NSMutableDictionary * resultsDict = [[NSMutableDictionary alloc] init];
    [resultsDict setObject:[requestData.agent objectForKey:@"Name"] forKey:@"agent"];
    [resultsDict setObject:[requestData.oid objectForKey:@"OID"] forKey:@"snmpObject"];
    [resultsDict setObject:@"[Bbs2]" forKey:@"resultObj"];
    [resultsDict setObject:@"" forKey:@"setValue"];
    [resultsDict setObject:@"SNMPWALK" forKey:@"action"];
    
    //Validate Request Data
    returnCode = [self validateRequestData:requestData];
    if(returnCode) {
        [resultsDict setObject:returnCode forKey:@"result"];
        [self addResultsToView:resultsDict];
        return returnCode;
    }
    
    // Create the pdu
    read_objid((char *)[[[requestData oid] objectForKey:@"OID"] UTF8String], session_snmpOID, &session_snmpOID_len);
    // !! Is there a way to check if read_objid was successful ?
    boobookRequestPdu = snmp_pdu_create(SNMP_MSG_GETNEXT);
    snmp_add_null_var(boobookRequestPdu, session_snmpOID, session_snmpOID_len);
    
    
    // Init Session
    NSString * sessionName = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    init_snmp([sessionName UTF8String]); // without this I get Engine ID error for v3
    snmp_sess_init( &boobookSnmpSession );
    // Here check for return error from snmp_sess_init() if any and raise Error
    
    // Set name of remote host; remote port (separated by ":") is part of it that net-snmnp lib takes care of
    boobookSnmpSession.peername = (char *)[[[requestData agent] objectForKey:@"Hostname"] UTF8String] ;
    
    // Configure Retries & Timeout values
    boobookSnmpSession.retries = (int)[[[requestData agent] objectForKey:@"Retries"] integerValue];
    /* Timeout is in microseconds */
    boobookSnmpSession.timeout = ([[[requestData agent] objectForKey:@"Timeout"] integerValue] * 1000000);
    
    //Populate SNMP Authentication data
    returnCode = [self populateSnmpAuthentication:requestData forSession:&boobookSnmpSession];
    if(returnCode) {
        // Clear/release boobookSnmpSession snmp_session structure!!!
        return returnCode;
    } // OR populate query array with result as Error: ...
    
    // Establish the session
    bbss = snmp_sess_open(&boobookSnmpSession);
    bbssp = snmp_sess_session(bbss);
    
    if (!bbss) {
        returnCode = [NSString stringWithFormat:@"Could not open snmp session to host: %@",[[requestData agent] objectForKey:@"Name"]];
        [resultsDict setValue:returnCode forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        //        snmp_sess_perror("snmpOp", &boobookSnmpSession);
        return returnCode;
    }
    
    //Set oid to compare check if we reached end of the tree
    session_snmpOID[session_snmpOID_len-1]++;
    // Send the PDU request
    snmpStatus = snmp_sess_synch_response(bbss, boobookRequestPdu, &boobookResponsePdu);
    //Cycle through the tree
    while(snmpStatus == STAT_SUCCESS && boobookResponsePdu->errstat == SNMP_ERR_NOERROR) {
        if ((boobookResponsePdu->variables)->type == SNMP_NOSUCHOBJECT) {
            returnCode = [NSString stringWithFormat:@"Object: %@ not available at this agent", @"requestPDU Object var Name"];
            [resultsDict setObject:returnCode forKey:@"resultValue"];
            [self addResultsToView:resultsDict];
            break;
        } else if ((boobookResponsePdu->variables)->type == SNMP_NOSUCHINSTANCE) {
            returnCode = [NSString stringWithFormat:@"Instance does not exists at this OID"];
            [resultsDict setObject:returnCode forKey:@"resultValue"];
            [self addResultsToView:resultsDict];
            break;
        } else if ((boobookResponsePdu->variables)->type == SNMP_ENDOFMIBVIEW) {
            returnCode = @"No more Objects left in this MIB View";
            [resultsDict setObject:returnCode forKey:@"resultValue"];
            [self addResultsToView:resultsDict];
            break;
        }
        // End of MIB Tree comparison check
        if(snmp_oid_compare(session_snmpOID, session_snmpOID_len, (boobookResponsePdu->variables)->name, (boobookResponsePdu->variables)->name_length) <= 0) {
            returnCode = @"SNMP Walk: End of Tree reached";
            [resultsDict setObject:returnCode forKey:@"resultValue"];
            [self addResultsToView:resultsDict];
            returnCode = nil;
            break;
        }
        //Populate values into display array
        for(snmpVars = boobookResponsePdu->variables; snmpVars; snmpVars = snmpVars->next_variable) {
            [resultsDict setObject:[self oidToName:snmpVars->name withObjectLength:snmpVars->name_length] forKey:@"resultObj"];
            [resultsDict setObject:[self variableOidToName:snmpVars withObject:snmpVars->name withObjectLength:snmpVars->name_length] forKey:@"resultValue"];
            [self addResultsToView:resultsDict];
        }
        //Generate next request
        boobookRequestPdu = nil;
        boobookRequestPdu = snmp_pdu_create(SNMP_MSG_GETNEXT);
        snmp_add_null_var(boobookRequestPdu, (boobookResponsePdu->variables)->name, (boobookResponsePdu->variables)->name_length);
        
        
        freePdu = boobookResponsePdu;
        boobookResponsePdu = nil;
        snmp_free_pdu(freePdu);
        
        snmpStatus = snmp_sess_synch_response(bbss, boobookRequestPdu, &boobookResponsePdu);
    }

    // Check for errors
    if (snmpStatus == STAT_TIMEOUT) {
        returnCode = [NSString stringWithFormat:@"Timeout getting response from host: %@", [requestData.agent objectForKey:@"Hostname"]];
        [resultsDict setObject:returnCode forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        
        snmp_sess_close(bbss);
        return returnCode;
    }
    if (snmpStatus != STAT_SUCCESS) {
        char           *err;
        snmp_sess_error(bbss, NULL, NULL, &err);
        returnCode = [NSString stringWithFormat:@"SNMP Request not successful: %s", err];
        [resultsDict setObject:returnCode forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        
        SNMP_FREE(err);
        snmp_sess_close(bbss);
        return returnCode;
    }
    if(!boobookResponsePdu) {
        [resultsDict setObject:[NSString stringWithFormat:@"Request was good, yet responsePDU was not received!"] forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        returnCode = [NSString stringWithFormat:@"Request was good, yet responsePDU was not received!"];
        
        snmp_sess_close(bbss);
        return returnCode;
    }
    if(boobookResponsePdu && boobookResponsePdu->errstat != SNMP_ERR_NOERROR) {
        [resultsDict setObject:[NSString stringWithFormat:@"%@",[self getPDUerrstring:boobookResponsePdu->errstat]] forKey:@"resultValue"];
        [self addResultsToView:resultsDict];
        returnCode = [NSString stringWithFormat:@"[BBS2] %@",[self getPDUerrstring:boobookResponsePdu->errstat]];
        
        snmp_sess_close(bbss);
        snmp_free_pdu(boobookResponsePdu);
        return returnCode;
    }
    
    //Cleanup
    if (boobookResponsePdu ) { snmp_free_pdu(boobookResponsePdu); }
    snmp_sess_close(bbss);
    
    return returnCode;
}

@end
