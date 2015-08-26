@isTest
private class ESBDaoTest {
    
    static testMethod void testGetRegistrationByRegistrationId() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        VTS_Registration reg = new DaoFactory().getEsbDao().getRegistrationByRegistrationId(428527);
        System.assertEquals(428527, reg.id);
        
        System.assertNotEquals(null, reg.candidate);
        System.assertNotEquals(null, reg.candidate.id);
        
        System.assertNotEquals(null, reg.exam);
        System.assertNotEquals(null, reg.exam.id);
        
        System.assertNotEquals(null, reg.testCenter);
        System.assertNotEquals(null, reg.testCenter.id);
        
    }
    
    static testMethod void testGetRegistrationByRegistrationIdVtsError() {
        VTS_Registration reg;
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        try {
            reg = new DaoFactory().getEsbDao().getRegistrationByRegistrationId(-1111);
            
            System.assert(true, 'Expecting error, but succeeded.');
            
        } catch(ESBException e) {
            system.debug('AA: reg:testGetRegistrationByRegistrationIdVtsError ' + reg );
            System.assertEquals('invalid_token', e.faultCode);
        }
    }
    
    static testMethod void testGetRegistrationByRegistrationIdEsbFault() {
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        try {
            VTS_Registration reg = new DaoFactory().getEsbDao().getRegistrationByRegistrationId(-9999);
            system.debug('RK: reg:testGetRegistrationByRegistrationIdEsbFault ' + reg );
            System.assert(true, 'Expecting error, but succeeded.');
        } catch(ESBException e) {
            System.debug('AA:exception' + e);
            System.assertEquals('Server', e.faultCode);
        }
        
    }
    
    static testMethod void testGetRegistrationsByTestCenterId () {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        LIST<VTS_Registration> regs = new DaoFactory().getEsbDao().getRegistrationsByTestCenterId(214302,system.today(),system.today());
        system.debug('RK:testGetRegistrationsByTestCenterId: '+regs);
        for ( VTS_Registration reg : regs ) {
            
            System.assertNotEquals(null, reg.id);
            
            System.assertNotEquals(null, reg.candidate);
            System.assertNotEquals(null, reg.appointmentTime);
            System.assertNotEquals(null, reg.appointmentTime.timestampInUTC);
            System.assertNotEquals(null, reg.appointmentTime.displayTimeZone);
            System.assertNotEquals(null, reg.appointmentTime.displayTimeZoneUTCOffset);
            System.assertNotEquals(null, reg.appointmentTime.displayTimeZoneSource);
            System.assertNotEquals(null, reg.exam);
            System.assertNotEquals(null, reg.exam.id);
            System.assertNotEquals(null, reg.exam.code);
            System.assertNotEquals(null, reg.exam.name);
            System.assertNotEquals(null, reg.testCenter);
            System.assertNotEquals(null, reg.testCenter.id);
            System.assertNotEquals(null, reg.testCenter.name);
            System.assertNotEquals(null, reg.testCenter.version);
            System.assertNotEquals(null, reg.testCenter.updateTrack);
            System.assertNotEquals(null, reg.testCenter.lastRMACompleted);
            System.assertNotEquals(null, reg.testCenter.lastUpdate);
            System.assertNotEquals(null, reg.testCenter.updateStatus);
            System.assertNotEquals(null, reg.testCenter.tedStatus);
            System.assertNotEquals(null, reg.testCenter.activeWorkstations);
            System.assertNotEquals(null, reg.testCenter.athenaVersion);
            System.assertNotEquals(null, reg.candidate.email);
            System.assertNotEquals(null, reg.candidate.clientId);
            System.assertNotEquals(null, reg.candidate.clientCandidateId);
            System.assertNotEquals(null, reg.candidate.middleInitial);
            System.assertNotEquals(null, reg.candidate.salutation);
            System.assertNotEquals(null, reg.candidate.suffix);
            System.assertNotEquals(null, reg.candidate.dob);
            System.assertNotEquals(null, reg.candidate.suffix);
            System.assertNotEquals(null, reg.candidate.clientCandidates);
            System.assertNotEquals(null, reg.candidate.clientCandidates[0].clientId);
            System.assertNotEquals(null, reg.candidate.clientCandidates[0].clientCandidateId);
            System.assertNotEquals(null, reg.candidate.alternateAddresses);
            
            System.assertNotEquals(null, reg.candidate.primaryAddress);
            System.assertNotEquals(null, reg.candidate.primaryAddress.country);
            System.assertNotEquals(null, reg.candidate.primaryAddress.extension);
            System.assertNotEquals(null, reg.candidate.primaryAddress.city);
            System.assertNotEquals(null, reg.candidate.primaryAddress.phone);
            System.assertNotEquals(null, reg.candidate.primaryAddress.postalCode);
            System.assertNotEquals(null, reg.candidate.primaryAddress.phoneCountryCode);
            System.assertNotEquals(null, reg.candidate.primaryAddress.state);
            System.assertNotEquals(null, reg.candidate.primaryAddress.address1);
            System.assertNotEquals(null, reg.candidate.primaryAddress.address2);
            System.assertNotEquals(null, reg.candidate.primaryAddress.addressType);
            System.assertNotEquals(null, reg.candidate.primaryAddress.address3);
            System.assertNotEquals(null, reg.candidate.primaryAddress.addressType);
            
            System.assertNotEquals(null, reg.deliveryMode);
            System.assertNotEquals(null, reg.deliveryMode.id);
            System.assertNotEquals(null, reg.deliveryMode.name);
            System.assertNotEquals(null, reg.deliveryMode.remoteMonitoring);
            System.assertNotEquals(null, reg.deliveryMode.remoteMonitoring.id);
            System.assertNotEquals(null, reg.deliveryMode.remoteMonitoring.name);
            System.assertNotEquals(null, reg.processStateCode);
            System.assertNotEquals(null, reg.disposition);
            
            System.assertNotEquals(null, reg.status);
            
            
        }
        LIST<VTS_Registration> regsnew = new DaoFactory().getEsbDao().getRegistrationsByCandidateId(214302);
        System.assertEquals(0, regs[0].CompareTo(regsnew[0]));
        regsnew[0].appointmentTime.timestampInUTC=099888;
        System.assertEquals(1, regs[0].CompareTo(regsnew[0]));
        regsnew[0].candidate.firstName='John Peter singh :P';
        System.assertEquals(1, regs[0].CompareTo(regsnew[0]));

        LIST<VTS_Registration> regs1 = new DaoFactory().getEsbDao().getRegistrationsByTestCenterId(214302);
    }
    
    static testMethod void testGetRegistrationByCandidateId() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        LIST<VTS_Registration> regs = new DaoFactory().getEsbDao().getRegistrationsByCandidateId(214302);
        system.debug('RK:testGetRegistrationByCandidateId: '+regs);
        for ( VTS_Registration reg : regs ) {
            
            System.assertNotEquals(null, reg.id);
            
            System.assertNotEquals(null, reg.candidate);
            System.assertNotEquals(null, reg.candidate.id);
            
            System.assertNotEquals(null, reg.exam);
            System.assertNotEquals(null, reg.exam.id);
            
            System.assertNotEquals(null, reg.testCenter);
            System.assertNotEquals(null, reg.testCenter.id);
            System.assertNotEquals(null, reg.candidate.email);
            System.assertNotEquals(null, reg.candidate.primaryAddress);
            System.assertNotEquals(null, reg.candidate.primaryAddress.country);
            System.assertNotEquals(null, reg.deliveryMode);
            System.assertNotEquals(null, reg.deliveryMode.id);
        }
        // for overloaded method
        LIST<VTS_Registration> regs1 = new DaoFactory().getEsbDao().getRegistrationsByCandidateId(214302,system.today(),system.today());
    }
    
    static testMethod void testGetRegistrationsByClientIdAndClientCandidateId() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        LIST<VTS_Registration> regs = new DaoFactory().getEsbDao().getRegistrationsByClientIdAndClientCandidateId(54, 'N714140');
        system.debug('RK:testGetRegistrationsByClientIdAndClientCandidateId'+regs);
        for ( VTS_Registration reg : regs ) {
            
            System.assertNotEquals(null, reg.id);
            
            System.assertNotEquals(null, reg.candidate);
            System.assertNotEquals(null, reg.candidate.id);
            
            System.assertNotEquals(null, reg.exam);
            System.assertNotEquals(null, reg.exam.id);
            
            System.assertNotEquals(null, reg.testCenter);
            System.assertNotEquals(null, reg.testCenter.id);
            System.assertNotEquals(null, reg.candidate.email);
            System.assertNotEquals(null, reg.candidate.primaryAddress);
            System.assertNotEquals(null, reg.candidate.primaryAddress.country);
            System.assertNotEquals(null, reg.deliveryMode);
            System.assertNotEquals(null, reg.deliveryMode.id);
            
        }
    }
    static testMethod void testgetCandidateByCandidateId() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        VTS_Candidate cand = new DaoFactory().getEsbDao().getCandidateByCandidateId(972819);
        System.assertNotEquals(null, cand.candidateid);
        
        System.assertNotEquals(null, cand.firstName);
        System.assertNotEquals(null, cand.lastName);
    }
    
    static testMethod void testgetCandidateByCandidateIdESBFault() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        boolean err = false;
        
        try {
            VTS_Candidate cand = new DaoFactory().getEsbDao().getCandidateByCandidateId(-1111);
            System.debug('RK: cand:testgetCandidateByCandidateIdESBFault '+cand);
        } catch(Exception ex) {
            err = true;
            
        }
        
        try {
            VTS_Candidate cand1 = new DaoFactory().getEsbDao().getCandidateByCandidateId(0000);
            System.debug('RK: cand:testgetCandidateByCandidateIdESBFault '+cand1);
        } catch(Exception ex) {
            err = true;
            
        }
        
        //System.assert(err);
    }
    
    static testMethod void testgetCandidateByCandidateIdVTSError() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        boolean err = false;
        try {
            VTS_Candidate cand = new DaoFactory().getEsbDao().getCandidateByCandidateId(-9999);
            System.debug('RK: cand:testgetCandidateByCandidateIdVTSError '+cand);
        } catch(Exception ex) {
            err = true;
        }
        
        //System.assert(err);
    }
    
    static testMethod void testgetCandidateByCandidateCriteria() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        VTS_Candidate.SearchCriteria cri = new VTS_Candidate.SearchCriteria();
        cri.clientId = '2506925';
        cri.clientCandidateID='98999';
        cri.firstName='john';
        cri.lastName='peter';
        cri.email='r@pearson.com';
        cri.phone='8909000';
        cri.birthDate=System.today();
        List<VTS_Candidate> cand = new DaoFactory().getEsbDao().getCandidatesByCriteria(cri);
        System.assertNotEquals(0, cand.size());
    }
    static testMethod void testgetCandidateByCandidateCriteriaESBFault() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        VTS_Candidate.SearchCriteria cri = new VTS_Candidate.SearchCriteria();
        boolean err = false;
        try {
            
            cri.clientId = '-1111';
            List<VTS_Candidate> cand = new DaoFactory().getEsbDao().getCandidatesByCriteria(cri);
            System.debug('RK: cand:testgetCandidateByCandidateCriteriaESBFault '+cand);
        } catch(Exception ex) {
            err = true;
        }
        System.assert(err);
        
    }
    static testMethod void testgetCandidateByCandidateCriteriaVTSError() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        VTS_Candidate.SearchCriteria cri = new VTS_Candidate.SearchCriteria();
        boolean err = false;
        try {
            
            cri.clientId = '-9999';
            List<VTS_Candidate> cand = new DaoFactory().getEsbDao().getCandidatesByCriteria(cri);
            System.debug('RK: cand:testgetCandidateByCandidateCriteriaVTSError '+cand);
        } catch(Exception ex) {
            err = true;
        }
        System.assert(err);
        
    }
    
    static testMethod void testGetTestCenterByTestCenterId() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        VTS_TestCenter center = new DaoFactory().getEsbDao().getTestCenterByTestCenterId(48509);
        System.assertEquals(48509, center.id);
        
        System.assertNotEquals(null, center.name);
        
        VTS_TestCenter center2 = new DaoFactory().getEsbDao().getTestCenterByTestCenterId(48509, new LIST<String>{'id', 'name'});
        System.assertEquals(48509, center2.id);
        System.assertNotEquals(null, center2.name);
        
        
    }

    static testMethod void testGetTestCenterByTestCenterIdVtsError() {
        VTS_TestCenter testCenter;
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        try {
            testCenter = new DaoFactory().getEsbDao().getTestCenterByTestCenterId(-1111);
            System.assert(true, 'Expecting error, but succeeded.');
        } catch(ESBException e) {
            System.assertEquals('invalid_token', e.faultCode);
        }
    }
    
    static testMethod void testGetTestCenterByTestCenterIdEsbFault() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        try {
            VTS_TestCenter testCenter = new DaoFactory().getEsbDao().getTestCenterByTestCenterId(-9999);
            System.assert(true, 'Expecting error, but succeeded.');
        } catch(ESBException e) {
            System.assertEquals('Server', e.faultCode);
        }
        
    }
    
    static testMethod void testGetcreateIncidentResultHold() {
        
        DataFactory.createSettings();
        DataFactory.createWebServiceSettings();
        VTS_Hold hold = new DaoFactory().getEsbDao().createIncidentResultHold(6600,'testing');
        System.assertEquals(6600, hold.id);
        
        System.assertNotEquals(null, hold.registrationID);
        
        
        System.assertNotEquals(null, hold.holdTypeCode);
        System.assertNotEquals(null, hold.comment);
        System.assertNotEquals(null, hold.vssTechID);
        System.assertNotEquals(null, hold.isActive);
        System.assertNotEquals(null, hold.createDate);
        System.assertEquals(null, hold.registration);
        
    }

}