import { LightningElement,api,track } from 'lwc';
import getquoteDetails from '@salesforce/apex/BAFCOQuotationReviseController.getquoteDetails';
import getRouteItem from '@salesforce/apex/BAFCOSalesOrderController.getRouteItem';
import getQuoteLineItem from '@salesforce/apex/BAFCOSalesOrderController.getQuoteLineItem';
import CONTAINER from '@salesforce/resourceUrl/AddContainer';
export default class BAFCOSalesOrderParent extends LightningElement {
    @api quoteID ='';
    @track quoteObj;
    @track accountAvgMargin = 0;
    @track accountBestMargin = 0;
    @track accountAvgCreditDays = 0;
    @track salesOrderList = [];
    @track equipList = [];
    @track activeTab = '';
    @track quantityDatalist = [];
    @track displayShip_consignee = false;
    @track customerAccount ;
    //@track quantityData = [];

    @track selectedRouteId ='';
    containerPng = CONTAINER;
    @track selectedDatalist =[];
    connectedCallback(){
        console.log('quotes ',this.quoteID)
        this.getquoteDetails();
    }
    getquoteDetails(){
        getquoteDetails({quoteId : this.quoteID})
        .then(result =>{
            console.log('getquoteDetails  result : ', JSON.stringify(result,null,2));
            if(result != null){
                this.quoteObj= result;
                this.accountAvgCreditDays = this.quoteObj.accountAvgCreditDays
                this.accountBestMargin = this.quoteObj.accountBestMargin
                this.accountAvgMargin = this.quoteObj.accountAvgMargin
                if(this.quoteObj.recordTypeName == 'Import') {
                    this.displayShip_consignee = true;
                    let accountobj = {
                        'accountId':this.quoteObj.companyId,
                        'accountName':this.quoteObj.company,
                    }
                    this.customerAccount = accountobj;
                    console.log('# '+JSON.stringify(this.customerAccount,null,2))
                }
                this.getRouteItem();
            }            
        }).catch(error=>{
            console.log('getquoteDetails error: ', JSON.stringify(error));
        });
    }
    getRouteItem(){
        getRouteItem({quoteId : this.quoteID})
        .then(result =>{
            //console.log('getRouteItem  result : ', JSON.stringify(result,null,2));
            let conts = result;
            for(let key in conts){
                this.salesOrderList.push({value:conts[key], key:key});
            }
            console.log('salesOrderList '+JSON.stringify(this.salesOrderList,null,2));
            let tempList = [];
            this.salesOrderList.forEach(elem=>{
                tempList.push({
                    routeName : elem.key,
                    routeId: elem.value.Id,
                    equipment:[],
                    displayKey:false
                })
            })
            this.selectedDatalist = tempList;

        }).catch(error=>{
            console.log('getRouteItem error: ', JSON.stringify(error));
        });
    }
    getQuoteLineItem(){
        console.log('this.quoteID',this.quoteID)
        console.log('this.selectedRouteId',this.selectedRouteId)
        getQuoteLineItem({
            quoteId : this.quoteID,
            routeId: this.selectedRouteId
        }).then(result =>{
            let conts = result;
            console.log('resukt '+JSON.stringify(result,null,2))
            for(let key in conts){
                this.equipList.push({value:conts[key], key:key,routeId: this.selectedRouteId});
            }
            console.log('equipList '+JSON.stringify(this.equipList,null,2));

            //reassign Data after change
            if(this.selectedDatalist.length > 0){
                this.selectedDatalist.forEach(elem => {
                    if(elem.routeId == this.selectedRouteId){
                        if(elem.equipment.length > 0){
                            elem.equipment.forEach(elem2=>{
                                this.equipList.forEach(elem3=>{
                                    if(elem3.key == elem2.key){
                                        elem2.value.forEach(elem4=>{
                                            elem3.value.forEach(elem5=>{
                                                if(elem4.shipName == elem5.shipName){
                                                    elem5.checkBoxSelected = elem4.checkBoxSelected
                                                    elem5.Qty = elem4.Qty
                                                }
                                            })
                                        })
                                    }
                                })
                            })
                        }
                    }
                });
            }
            
        }).catch(error=>{
            console.log('getQuoteLineItem error: ', JSON.stringify(error));
        });
    }
    handleTabActive(e){         
        this.equipList = [];
        let routeName = e.target.value;
        this.activeTab = routeName;
        this.salesOrderList.forEach(elem=>{
            if(elem.key == routeName){
                this.selectedRouteId = elem.value.Id;
            }
        })
        this.getQuoteLineItem();
    }
        handleItemQuantitychange(e){
        let quantity = e.target.value;
        if(quantity == ''){
            quantity = 0;
        }
        let equip = e.target.dataset.equip;
        let shipline = e.target.dataset.shipline;
        this.selectedDatalist.forEach(elem=>{
            if(elem.routeId == this.selectedRouteId){
                if(elem.equipment.length == 0){
                    let tempList = [];
                    tempList.push({
                        shipName: shipline,
                        Qty:quantity,
                        
                    })
                    elem.equipment.push({
                        key:equip,
                        value:tempList
                    });
                }else{
                    let index = elem.equipment.findIndex(e => e.key === equip);
                    if(index == -1){
                        let tempList = [];
                        tempList.push({
                             shipName: shipline,
                             Qty:quantity,
                        })
                        elem.equipment.push({
                            key:equip,
                            value:tempList
                        });
                    }
                    else{
                        let tempList = elem.equipment[index].value;
                        let shipIndex = tempList.findIndex(e => e.shipName === shipline); 
                        if(shipIndex != -1) tempList[shipIndex].Qty = quantity;
                        else{
                            tempList.push({
                                shipName: shipline,
                                Qty:quantity,
                           })
                        }
                        elem.equipment[index].value  = tempList;
                    }
                }
            }
        })
        console.log('** '+JSON.stringify(this.selectedDatalist,null,2))
    }
    handleCheckBoxClicked(e){
        let checked = e.target.checked;
        let equip = e.target.dataset.equip;
        let shipline = e.target.dataset.shipline;
        let sellingTotal = e.target.dataset.sellingtotal;
        let index = this.equipList.findIndex(e => e.key == equip);
        let equipValue = this.equipList[index].value;
        let shipIndex = equipValue.findIndex(e=> e.shipName == shipline);
        let shipValue = equipValue[shipIndex];
        if(checked){
            this.selectedDatalist.forEach(elem=>{
                if(elem.routeId == this.selectedRouteId){
                    if(elem.equipment.length == 0){
                        let tempList = [];
                        tempList.push({
                            shipName: shipline,
                            Qty:shipValue.Qty,
                            sellingTotal: sellingTotal,
                            checkBoxSelected: true,
                            accountId: shipValue.accountId,
                            baf: shipValue.baf,
                            bayan: shipValue.baf,
                            bayanCancellation: shipValue.bayanCancellation,
                            bunkerSurcharge: shipValue.bunkerSurcharge,
                            cleaningCharges: shipValue.cleaningCharges,
                            containerLashing: shipValue.containerLashing,
                            containerMaintenance: shipValue.containerMaintenance,
                            containerMovement: shipValue.containerMovement,
                            containerStripping: shipValue.containerStripping,
                            destinationCustomClearnace: shipValue.destinationCustomClearnace,
                            destinationLoading: shipValue.destinationLoading,
                            dthc: shipValue.dthc,
                            eic: shipValue.eic,
                            enquiryId: shipValue.enquiryId,
                            equipmentType: shipValue.equipmentType,
                            fasahFee: shipValue.fasahFee,
                            freeTimeCertification: shipValue.freeTimeCertification,
                            fumigation: shipValue.fumigation,
                            inspection: shipValue.inspection,
                            insurance: shipValue.insurance,
                            isps: shipValue.isps,
                            leadId: shipValue.leadId,
                            liftOnOff: shipValue.liftOnOff,
                            loadingCharges: shipValue.loadingCharges,
                            ministryClearance: shipValue.ministryClearance,
                            miscallenous: shipValue.miscallenous,
                            mot: shipValue.mot,
                            nonPatellized: shipValue.nonPatellized,
                            originCustomClearance: shipValue.originCustomClearance,
                            originloadingCharges: shipValue.originloadingCharges,
                            othc: shipValue.othc,
                            pestController: shipValue.pestController,
                            portShuttling: shipValue.portShuttling,
                            postOfDischarge: shipValue.postOfDischarge,
                            postOfLoading: shipValue.postOfLoading,
                            quotationId: shipValue.quotationId,
                            refeerCentr: shipValue.refeerCentr,
                            refeerPTI: shipValue.refeerPTI,
                            refeerSteamWash: shipValue.refeerSteamWash,
                            rePalletization: shipValue.rePalletization,
                            rmsID: shipValue.rmsID,
                            routeID: shipValue.routeID,
                            seaFreight: shipValue.seaFreight,
                            sealCharges: shipValue.sealCharges,
                            sellingRate: shipValue.sellingRate,
                            stuffingCharges: shipValue.stuffingCharges,
                            sweepingCleaning: shipValue.sweepingCleaning,
                            tabadul: shipValue.tabadul,
                            tarapulin: shipValue.tarapulin,
                            totalInco: shipValue.totalInco,
                            totalSL: shipValue.totalSL,
                            truckHead: shipValue.truckHead,
                            truckIdealing: shipValue.truckIdealing,
                            vesselCertificate: shipValue.vesselCertificate,
                            wrappingPacking: shipValue.wrappingPacking,
                            xRay: shipValue.xRay,
                            bayanCharges : shipValue.bayanCharges,
                            blFees : shipValue.blFees,
                            carriageCongestionSurcharge : shipValue.carriageCongestionSurcharge,
                            dgSurcharge : shipValue.dgSurcharge,
                            exportServiceFees : shipValue.exportServiceFees,
                            fasahCharges : shipValue.fasahCharges,
                            fuelSurcharges : shipValue.fuelSurcharges,
                            gatePassCharges : shipValue.gatePassCharges,
                            inlandFuelSurcharges : shipValue.inlandFuelSurcharges,
                            inlandHandlingFees : shipValue.inlandHandlingFees,
                            inlandHaulage : shipValue.inlandHaulage,
                            lowSulpherSurcharge : shipValue.lowSulpherSurcharge,
                            operationalRecoverySurcharge : shipValue.operationalRecoverySurcharge,
                            lashingCharges : shipValue.lashingCharges,
                            originDetentionCharges : shipValue.originDetentionCharges,
                            overWeightSurcharge : shipValue.overWeightSurcharge,
                            pickupCharges : shipValue.pickupCharges,
                            totalDestination : shipValue.totalDestination,
                            vgm : shipValue.vgm,
                            warRiskCharges : shipValue.warRiskCharges,
                            totalAdditional : shipValue.totalAdditional,
                            remarksAdditionalCharges : shipValue.remarksAdditionalCharges,
                            remarksDesinationCharges : shipValue.remarksDesinationCharges,
                            remarksoriginCharges : shipValue.remarksoriginCharges,
                            remarksSLCharges : shipValue.remarksSLCharges,
                            containerLashingCharges : shipValue.containerLashingCharges,
                            dOcharges : shipValue.dOcharges,
                            lOLOCharges : shipValue.lOLOCharges,
                            carrierSecurityFees : shipValue.carrierSecurityFees,
                            recordtypeId : shipValue.recordtypeId,
                            pickupPlace:shipValue.pickupPlace,
                            dischargePlace:shipValue.dischargePlace,
                            addServiceCharge:shipValue.addServiceCharge,
                            addOriginCharge:shipValue.addOriginCharge,
                            addDestinCharge:shipValue.addDestinCharge,
                            addAdditionalCharge:shipValue.addAdditionalCharge,
                            addExWorksCharge:shipValue.addExWorksCharge,
                            includeServiceCharge:shipValue.includeServiceCharge,
                            includeOriginCharge:shipValue.includeOriginCharge,
                            includeDestinCharge:shipValue.includeDestinCharge,
                            includeAdditionalCharge:shipValue.includeAdditionalCharge,
                            includeExWorksCharge:shipValue.includeExWorksCharge,
                            exWorksId:shipValue.exWorksId,
                            exWorksCharge:shipValue.exWorksCharge,
                            AlternateDepotReleaseCharges:shipValue.AlternateDepotReleaseCharges,
                            FreightDifference:shipValue.FreightDifference,
                            CarrierContainerRepositioningCharges:shipValue.CarrierContainerRepositioningCharges,
                            orderBuyingRate:shipValue.orderBuyingRate,
                            shippLine:shipValue.shippLine,
                            quoteItemId:shipValue.quoteItemId,
                            agentId:shipValue.agentId,
                        })
                        elem.equipment.push({
                            key:equip,
                            value:tempList,
                            displayKey:true,
                        });
                    }
                    else{
                        let index = elem.equipment.findIndex(e => e.key === equip);
                        if(index == -1){
                            let tempList = [];
                            tempList.push({
                                shipName: shipline,
                                sellingTotal: sellingTotal,
                                Qty:shipValue.Qty,
                                checkBoxSelected: true,
                                baf: shipValue.baf,
                                bayan: shipValue.baf,
                                accountId: shipValue.accountId,
                                bayanCancellation: shipValue.bayanCancellation,
                                bunkerSurcharge: shipValue.bunkerSurcharge,
                                cleaningCharges: shipValue.cleaningCharges,
                                containerLashing: shipValue.containerLashing,
                                containerMaintenance: shipValue.containerMaintenance,
                                containerMovement: shipValue.containerMovement,
                                containerStripping: shipValue.containerStripping,
                                destinationCustomClearnace: shipValue.destinationCustomClearnace,
                                destinationLoading: shipValue.destinationLoading,
                                dthc: shipValue.dthc,
                                eic: shipValue.eic,
                                enquiryId: shipValue.enquiryId,
                                equipmentType: shipValue.equipmentType,
                                fasahFee: shipValue.fasahFee,
                                freeTimeCertification: shipValue.freeTimeCertification,
                                fumigation: shipValue.fumigation,
                                inspection: shipValue.inspection,
                                insurance: shipValue.insurance,
                                isps: shipValue.isps,
                                leadId: shipValue.leadId,
                                liftOnOff: shipValue.liftOnOff,
                                loadingCharges: shipValue.loadingCharges,
                                ministryClearance: shipValue.ministryClearance,
                                miscallenous: shipValue.miscallenous,
                                mot: shipValue.mot,
                                nonPatellized: shipValue.nonPatellized,
                                originCustomClearance: shipValue.originCustomClearance,
                                originloadingCharges: shipValue.originloadingCharges,
                                othc: shipValue.othc,
                                pestController: shipValue.pestController,
                                portShuttling: shipValue.portShuttling,
                                postOfDischarge: shipValue.postOfDischarge,
                                postOfLoading: shipValue.postOfLoading,
                                quotationId: shipValue.quotationId,
                                refeerCentr: shipValue.refeerCentr,
                                refeerPTI: shipValue.refeerPTI,
                                refeerSteamWash: shipValue.refeerSteamWash,
                                rePalletization: shipValue.rePalletization,
                                rmsID: shipValue.rmsID,
                                routeID: shipValue.routeID,
                                seaFreight: shipValue.seaFreight,
                                sealCharges: shipValue.sealCharges,
                                sellingRate: shipValue.sellingRate,
                                stuffingCharges: shipValue.stuffingCharges,
                                sweepingCleaning: shipValue.sweepingCleaning,
                                tabadul: shipValue.tabadul,
                                tarapulin: shipValue.tarapulin,
                                totalInco: shipValue.totalInco,
                                totalSL: shipValue.totalSL,
                                truckHead: shipValue.truckHead,
                                truckIdealing: shipValue.truckIdealing,
                                vesselCertificate: shipValue.vesselCertificate,
                                wrappingPacking: shipValue.wrappingPacking,
                                xRay: shipValue.xRay,
                                bayanCharges : shipValue.bayanCharges,
                                blFees : shipValue.blFees,
                                carriageCongestionSurcharge : shipValue.carriageCongestionSurcharge,
                                dgSurcharge : shipValue.dgSurcharge,
                                exportServiceFees : shipValue.exportServiceFees,
                                fasahCharges : shipValue.fasahCharges,
                                fuelSurcharges : shipValue.fuelSurcharges,
                                gatePassCharges : shipValue.gatePassCharges,
                                inlandFuelSurcharges : shipValue.inlandFuelSurcharges,
                                inlandHandlingFees : shipValue.inlandHandlingFees,
                                inlandHaulage : shipValue.inlandHaulage,
                                lowSulpherSurcharge : shipValue.lowSulpherSurcharge,
                                operationalRecoverySurcharge : shipValue.operationalRecoverySurcharge,
                                lashingCharges : shipValue.lashingCharges,
                                originDetentionCharges : shipValue.originDetentionCharges,
                                overWeightSurcharge : shipValue.overWeightSurcharge,
                                pickupCharges : shipValue.pickupCharges,
                                totalDestination : shipValue.totalDestination,
                                vgm : shipValue.vgm,
                                warRiskCharges : shipValue.warRiskCharges,
                                totalAdditional : shipValue.totalAdditional,
                                remarksAdditionalCharges : shipValue.remarksAdditionalCharges,
                                remarksDesinationCharges : shipValue.remarksDesinationCharges,
                                remarksoriginCharges : shipValue.remarksoriginCharges,
                                remarksSLCharges : shipValue.remarksSLCharges,
                                containerLashingCharges : shipValue.containerLashingCharges,
                                dOcharges : shipValue.dOcharges,
                                lOLOCharges : shipValue.lOLOCharges,
                                carrierSecurityFees : shipValue.carrierSecurityFees,
                                recordtypeId : shipValue.recordtypeId,
                                pickupPlace:shipValue.pickupPlace,
                                dischargePlace:shipValue.dischargePlace,
                                addServiceCharge:shipValue.addServiceCharge,
                                addOriginCharge:shipValue.addOriginCharge,
                                addDestinCharge:shipValue.addDestinCharge,
                                addAdditionalCharge:shipValue.addAdditionalCharge,
                                addExWorksCharge:shipValue.addExWorksCharge,
                                includeServiceCharge:shipValue.includeServiceCharge,
                                includeOriginCharge:shipValue.includeOriginCharge,
                                includeDestinCharge:shipValue.includeDestinCharge,
                                includeAdditionalCharge:shipValue.includeAdditionalCharge,
                                includeExWorksCharge:shipValue.includeExWorksCharge,
                                exWorksId:shipValue.exWorksId,
                                exWorksCharge:shipValue.exWorksCharge,
                                AlternateDepotReleaseCharges:shipValue.AlternateDepotReleaseCharges,
                                FreightDifference:shipValue.FreightDifference,
                                CarrierContainerRepositioningCharges:shipValue.CarrierContainerRepositioningCharges,
                                orderBuyingRate:shipValue.orderBuyingRate,
                                shippLine:shipValue.shippLine,
                                quoteItemId:shipValue.quoteItemId,
                                agentId:shipValue.agentId,
                            })
                            elem.equipment.push({
                                key:equip,
                                value:tempList,
                                displayKey:true
                            });
                        }
                        else{
                            let tempList = elem.equipment[index].value;
                            let shipIndex = tempList.findIndex(e => e.shipName === shipline);
                            if(shipIndex != -1){
                                tempList[shipIndex].shipName = shipline;
                                tempList[shipIndex].sellingTotal = sellingTotal
                                tempList[shipIndex].checkBoxSelected = true
                                tempList[shipIndex].baf =  shipValue.baf
                                tempList[shipIndex].bayan =  shipValue.bayan
                                tempList[shipIndex].accountId =  shipValue.accountId
                                tempList[shipIndex].bayanCancellation =  shipValue.bayanCancellation
                                tempList[shipIndex].bunkerSurcharge =  shipValue.bunkerSurcharge
                                tempList[shipIndex].cleaningCharges =  shipValue.cleaningCharges
                                tempList[shipIndex].containerLashing =  shipValue.containerLashing
                                tempList[shipIndex].containerMaintenance =  shipValue.containerMaintenance
                                tempList[shipIndex].containerMovement =  shipValue.containerMovement
                                tempList[shipIndex].containerStripping =  shipValue.containerStripping
                                tempList[shipIndex].destinationCustomClearnace =  shipValue.destinationCustomClearnace
                                tempList[shipIndex].destinationLoading =  shipValue.destinationLoading
                                tempList[shipIndex].dthc =  shipValue.dthc
                                tempList[shipIndex].eic =  shipValue.eic
                                tempList[shipIndex].enquiryId =  shipValue.enquiryId
                                tempList[shipIndex].equipmentType =  shipValue.equipmentType
                                tempList[shipIndex].fasahFee =  shipValue.fasahFee
                                tempList[shipIndex].freeTimeCertification =  shipValue.freeTimeCertification
                                tempList[shipIndex].fumigation =  shipValue.fumigation
                                tempList[shipIndex].inspection =  shipValue.inspection
                                tempList[shipIndex].insurance =  shipValue.insurance
                                tempList[shipIndex].isps =  shipValue.isps
                                tempList[shipIndex].leadId =  shipValue.leadId
                                tempList[shipIndex].liftOnOff =  shipValue.liftOnOff
                                tempList[shipIndex].loadingCharges =  shipValue.loadingCharges
                                tempList[shipIndex].ministryClearance =  shipValue.ministryClearance
                                tempList[shipIndex].miscallenous =  shipValue.miscallenous
                                tempList[shipIndex].mot =  shipValue.mot
                                tempList[shipIndex].nonPatellized =  shipValue.nonPatellized
                                tempList[shipIndex].originCustomClearance =  shipValue.originCustomClearance
                                tempList[shipIndex].originloadingCharges =  shipValue.originloadingCharges
                                tempList[shipIndex].othc =  shipValue.othc
                                tempList[shipIndex].pestController =  shipValue.pestController
                                tempList[shipIndex].portShuttling =  shipValue.portShuttling
                                tempList[shipIndex].postOfDischarge =  shipValue.postOfDischarge
                                tempList[shipIndex].postOfLoading =  shipValue.postOfLoading
                                tempList[shipIndex].quotationId =  shipValue.quotationId
                                tempList[shipIndex].refeerCentr =  shipValue.refeerCentr
                                tempList[shipIndex].refeerPTI =  shipValue.refeerPTI
                                tempList[shipIndex].refeerSteamWash =  shipValue.refeerSteamWash
                                tempList[shipIndex].rePalletization =  shipValue.rePalletization
                                tempList[shipIndex].rmsID =  shipValue.rmsID
                                tempList[shipIndex].routeID =  shipValue.routeID
                                tempList[shipIndex].seaFreight =  shipValue.seaFreight
                                tempList[shipIndex].sealCharges =  shipValue.sealCharges
                                tempList[shipIndex].sellingRate =  shipValue.sellingRate
                                tempList[shipIndex].stuffingCharges = shipValue.stuffingCharges
                                tempList[shipIndex].sweepingCleaning =  shipValue.sweepingCleaning
                                tempList[shipIndex].tabadul =  shipValue.tabadul
                                tempList[shipIndex].tarapulin =  shipValue.tarapulin
                                tempList[shipIndex].totalInco =  shipValue.totalInco
                                tempList[shipIndex].totalSL =  shipValue.totalSL
                                tempList[shipIndex].truckHead = shipValue.truckHead
                                tempList[shipIndex].truckIdealing = shipValue.truckIdealing
                                tempList[shipIndex].vesselCertificate =  shipValue.vesselCertificate
                                tempList[shipIndex].wrappingPacking =  shipValue.wrappingPacking
                                tempList[shipIndex].xRay =  shipValue.xRay
                                tempList[shipIndex].bayanCharges = shipValue.bayanCharges
                                tempList[shipIndex].blFees = shipValue.blFees
                                tempList[shipIndex].carriageCongestionSurcharge = shipValue.carriageCongestionSurcharge
                                tempList[shipIndex].dgSurcharge = shipValue.dgSurcharge
                                tempList[shipIndex].exportServiceFees = shipValue.exportServiceFees
                                tempList[shipIndex].fasahCharges = shipValue.fasahCharges
                                tempList[shipIndex].fuelSurcharges = shipValue.fuelSurcharges
                                tempList[shipIndex].gatePassCharges = shipValue.gatePassCharges
                                tempList[shipIndex].inlandFuelSurcharges = shipValue.inlandFuelSurcharges
                                tempList[shipIndex].inlandHandlingFees = shipValue.inlandHandlingFees
                                tempList[shipIndex].inlandHaulage = shipValue.inlandHaulage
                                tempList[shipIndex].lowSulpherSurcharge = shipValue.lowSulpherSurcharge
                                tempList[shipIndex].operationalRecoverySurcharge = shipValue.operationalRecoverySurcharge
                                tempList[shipIndex].lashingCharges = shipValue.lashingCharges
                                tempList[shipIndex].originDetentionCharges = shipValue.originDetentionCharges
                                tempList[shipIndex].overWeightSurcharge = shipValue.overWeightSurcharge
                                tempList[shipIndex].pickupCharges = shipValue.pickupCharges
                                tempList[shipIndex].totalDestination = shipValue.totalDestination
                                tempList[shipIndex].vgm = shipValue.vgm
                                tempList[shipIndex].warRiskCharges = shipValue.warRiskCharges
                                tempList[shipIndex].totalAdditional = shipValue.totalAdditional
                                tempList[shipIndex].remarksAdditionalCharges = shipValue.remarksAdditionalCharges
                                tempList[shipIndex].remarksDesinationCharges = shipValue.remarksDesinationCharges
                                tempList[shipIndex].remarksoriginCharges = shipValue.remarksoriginCharges
                                tempList[shipIndex].remarksSLCharges = shipValue.remarksSLCharges
                                tempList[shipIndex].containerLashingCharges = shipValue.containerLashingCharges
                                tempList[shipIndex].dOcharges= shipValue.dOcharges
                                tempList[shipIndex].lOLOCharges = shipValue.lOLOCharges
                                tempList[shipIndex].carrierSecurityFees = shipValue.carrierSecurityFees
                                tempList[shipIndex].recordtypeId = shipValue.recordtypeId
                                tempList[shipIndex].pickupPlace=shipValue.pickupPlace
                                tempList[shipIndex].dischargePlace=shipValue.dischargePlace
                                tempList[shipIndex].addServiceCharge=shipValue.addServiceCharge
                                tempList[shipIndex].addOriginCharge=shipValue.addOriginCharge
                                tempList[shipIndex].addDestinCharge=shipValue.addDestinCharge
                                tempList[shipIndex].addAdditionalCharge=shipValue.addAdditionalCharge
                                tempList[shipIndex].addExWorksCharge=shipValue.addExWorksCharge
                                tempList[shipIndex].includeServiceCharge=shipValue.includeServiceCharge
                                tempList[shipIndex].includeOriginCharge=shipValue.includeOriginCharge
                                tempList[shipIndex].includeDestinCharge=shipValue.includeDestinCharge
                                tempList[shipIndex].includeAdditionalCharge=shipValue.includeAdditionalCharge
                                tempList[shipIndex].includeExWorksCharge=shipValue.includeExWorksCharge
                                tempList[shipIndex].exWorksId=shipValue.exWorksId
                                tempList[shipIndex].exWorksCharge=shipValue.exWorksCharge
                                tempList[shipIndex].AlternateDepotReleaseCharges=shipValue.AlternateDepotReleaseCharges
                                tempList[shipIndex].FreightDifference=shipValue.FreightDifference
                                tempList[shipIndex].CarrierContainerRepositioningCharges=shipValue.CarrierContainerRepositioningCharges
                                tempList[shipIndex].orderBuyingRate=shipValue.orderBuyingRate;
                                tempList[shipIndex].shippLine = shipValue.shippLine;
                                tempList[shipIndex].quoteItemId = shipValue.quoteItemId;
                                tempList[shipIndex].agentId = shipValue.agentId;
                            }
                            else{
                                tempList.push({
                                    shipName: shipline,
                                    sellingTotal: sellingTotal,
                                    Qty:shipValue.Qty,
                                    checkBoxSelected: true,
                                    baf: shipValue.baf,
                                    bayan: shipValue.baf,
                                    accountId: shipValue.accountId,
                                    bayanCancellation: shipValue.bayanCancellation,
                                    bunkerSurcharge: shipValue.bunkerSurcharge,
                                    cleaningCharges: shipValue.cleaningCharges,
                                    containerLashing: shipValue.containerLashing,
                                    containerMaintenance: shipValue.containerMaintenance,
                                    containerMovement: shipValue.containerMovement,
                                    containerStripping: shipValue.containerStripping,
                                    destinationCustomClearnace: shipValue.destinationCustomClearnace,
                                    destinationLoading: shipValue.destinationLoading,
                                    dthc: shipValue.dthc,
                                    eic: shipValue.eic,
                                    enquiryId: shipValue.enquiryId,
                                    equipmentType: shipValue.equipmentType,
                                    fasahFee: shipValue.fasahFee,
                                    freeTimeCertification: shipValue.freeTimeCertification,
                                    fumigation: shipValue.fumigation,
                                    inspection: shipValue.inspection,
                                    insurance: shipValue.insurance,
                                    isps: shipValue.isps,
                                    leadId: shipValue.leadId,
                                    liftOnOff: shipValue.liftOnOff,
                                    loadingCharges: shipValue.loadingCharges,
                                    ministryClearance: shipValue.ministryClearance,
                                    miscallenous: shipValue.miscallenous,
                                    mot: shipValue.mot,
                                    nonPatellized: shipValue.nonPatellized,
                                    originCustomClearance: shipValue.originCustomClearance,
                                    originloadingCharges: shipValue.originloadingCharges,
                                    othc: shipValue.othc,
                                    pestController: shipValue.pestController,
                                    portShuttling: shipValue.portShuttling,
                                    postOfDischarge: shipValue.postOfDischarge,
                                    postOfLoading: shipValue.postOfLoading,
                                    quotationId: shipValue.quotationId,
                                    refeerCentr: shipValue.refeerCentr,
                                    refeerPTI: shipValue.refeerPTI,
                                    refeerSteamWash: shipValue.refeerSteamWash,
                                    rePalletization: shipValue.rePalletization,
                                    rmsID: shipValue.rmsID,
                                    routeID: shipValue.routeID,
                                    seaFreight: shipValue.seaFreight,
                                    sealCharges: shipValue.sealCharges,
                                    sellingRate: shipValue.sellingRate,
                                    stuffingCharges: shipValue.stuffingCharges,
                                    sweepingCleaning: shipValue.sweepingCleaning,
                                    tabadul: shipValue.tabadul,
                                    tarapulin: shipValue.tarapulin,
                                    totalInco: shipValue.totalInco,
                                    totalSL: shipValue.totalSL,
                                    truckHead: shipValue.truckHead,
                                    truckIdealing: shipValue.truckIdealing,
                                    vesselCertificate: shipValue.vesselCertificate,
                                    wrappingPacking: shipValue.wrappingPacking,
                                    xRay: shipValue.xRay,
                                    bayanCharges : shipValue.bayanCharges,
                                    blFees : shipValue.blFees,
                                    carriageCongestionSurcharge : shipValue.carriageCongestionSurcharge,
                                    dgSurcharge : shipValue.dgSurcharge,
                                    exportServiceFees : shipValue.exportServiceFees,
                                    fasahCharges : shipValue.fasahCharges,
                                    fuelSurcharges : shipValue.fuelSurcharges,
                                    gatePassCharges : shipValue.gatePassCharges,
                                    inlandFuelSurcharges : shipValue.inlandFuelSurcharges,
                                    inlandHandlingFees : shipValue.inlandHandlingFees,
                                    inlandHaulage : shipValue.inlandHaulage,
                                    lowSulpherSurcharge : shipValue.lowSulpherSurcharge,
                                    operationalRecoverySurcharge : shipValue.operationalRecoverySurcharge,
                                    lashingCharges : shipValue.lashingCharges,
                                    originDetentionCharges : shipValue.originDetentionCharges,
                                    overWeightSurcharge : shipValue.overWeightSurcharge,
                                    pickupCharges : shipValue.pickupCharges,
                                    totalDestination : shipValue.totalDestination,
                                    vgm : shipValue.vgm,
                                    warRiskCharges : shipValue.warRiskCharges,
                                    totalAdditional : shipValue.totalAdditional,
                                    remarksAdditionalCharges : shipValue.remarksAdditionalCharges,
                                    remarksDesinationCharges : shipValue.remarksDesinationCharges,
                                    remarksoriginCharges : shipValue.remarksoriginCharges,
                                    remarksSLCharges : shipValue.remarksSLCharges,
                                    containerLashingCharges : shipValue.containerLashingCharges,
                                    dOcharges : shipValue.dOcharges,
                                    lOLOCharges : shipValue.lOLOCharges,
                                    carrierSecurityFees : shipValue.carrierSecurityFees,
                                    recordtypeId : shipValue.recordtypeId,
                                    pickupPlace:shipValue.pickupPlace,
                                    dischargePlace:shipValue.dischargePlace,
                                    addServiceCharge:shipValue.addServiceCharge,
                                    addOriginCharge:shipValue.addOriginCharge,
                                    addDestinCharge:shipValue.addDestinCharge,
                                    addAdditionalCharge:shipValue.addAdditionalCharge,
                                    addExWorksCharge:shipValue.addExWorksCharge,
                                    includeServiceCharge:shipValue.includeServiceCharge,
                                    includeOriginCharge:shipValue.includeOriginCharge,
                                    includeDestinCharge:shipValue.includeDestinCharge,
                                    includeAdditionalCharge:shipValue.includeAdditionalCharge,
                                    includeExWorksCharge:shipValue.includeExWorksCharge,
                                    exWorksId:shipValue.exWorksId,
                                    exWorksCharge:shipValue.exWorksCharge,
                                    AlternateDepotReleaseCharges:shipValue.AlternateDepotReleaseCharges,
                                    FreightDifference:shipValue.FreightDifference,
                                    CarrierContainerRepositioningCharges:shipValue.CarrierContainerRepositioningCharges,
                                    orderBuyingRate:shipValue.orderBuyingRate,
                                    shippLine:shipValue.shippLine,
                                    quoteItemId:shipValue.quoteItemId,
                                    agentId:shipValue.agentId,
                                })
                            }
                            elem.equipment[index].value = tempList
                        }
                    }
                }
            })
        }
        else{
            this.selectedDatalist.forEach(elem=>{
                if(elem.routeId == this.selectedRouteId){
                    let index = elem.equipment.findIndex(e => e.key === equip);
                    let templist = elem.equipment[index].value;
                    templist.forEach((ship,ind,templist)=>{
                        if(ship.shipName == shipline){
                            templist.splice(ind, 1);
                        }
                    });
                    elem.equipment[index].value = templist;
                    if(elem.equipment[index].value.length == 0){
                        elem.equipment.splice(index,1);
                    }
                }
            })
        }
        console.log('selectd '+JSON.stringify(this.selectedDatalist,null,2));
        this.template.querySelector('c-b-a-f-c-o-sales-order-list').handlecheckBoxSelected();

    }
    assignData(){
        
    }
    
}