// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract DonorHistory{
    struct History{
        uint amount;
        uint campaignId;
    }
    mapping(address=>History[]) public donorHistory;
    function addToHistory(uint _amount,uint _campaignId, address _donor) public payable {
        donorHistory[_donor].push(History({
            amount:_amount,
            campaignId:_campaignId
        }));
    }
    function getDonorHistory(address _donor) public view returns(History[] memory){
        return donorHistory[_donor];
    }
}

contract CampaignDonors {
    struct CampaignDonor{
        address donor;
        uint amount;
    }
    mapping(uint=>CampaignDonor[]) public campaignDonor;
    function addDonorToCampaign(uint _id, uint _value, address _donor) public {
        campaignDonor[_id].push(CampaignDonor({
            amount:_value,
            donor:_donor
        }));
    } 
    function getCampaignDonors(uint _id) public view returns(CampaignDonor[] memory){
        return campaignDonor[_id];
    }
} 

contract CrowdFunding{
    struct Campaign{
        address payable receipientAddress;
        string title;
        string description;
        string imageUrl;
        uint target;
        string deadline;
        uint received;
        uint id;
        bool completed;
    }
    Campaign[] public campaigns;
    DonorHistory public donorHistory;
    CampaignDonors public campaignDonorsList;
    constructor(){
        donorHistory = new DonorHistory();
        campaignDonorsList = new CampaignDonors();
    }
    uint public numberOfCampaigns = 0;
    function addCampaigns(string memory _title, string memory _description, string memory _imageUrl, uint _target, string memory _deadline ) public {
        require(_target > 0,"Target amount must not be zero");
        campaigns.push(Campaign({
            receipientAddress:payable(msg.sender),
            title:_title,
            description:_description,
            imageUrl:_imageUrl,
            target:_target,
            deadline:_deadline,
            received:0,
            id:numberOfCampaigns,
            completed:false
        }));
        numberOfCampaigns++;
    }
    function getDonorDonationHistory(address _address) public view returns (DonorHistory.History[] memory) {
        return donorHistory.getDonorHistory(_address);
    }
    function getCampaignDonorsList(uint _id) public view returns(CampaignDonors.CampaignDonor[] memory) {
        return campaignDonorsList.getCampaignDonors(_id);
    }
    function getCampaigns() public view returns(Campaign[] memory){
        return campaigns;
    } 
    function getCampaignDetails(uint index) public view returns(Campaign memory){
        Campaign memory campaign = campaigns[index];
        return campaign;
    }

    function donateToCampaign(uint index) public payable {
        require(index < campaigns.length, "Invalid campaign index");
        Campaign storage campaign = campaigns[index];
        require(!campaign.completed,"Campaign completed");
        campaign.receipientAddress.transfer(msg.value);
        campaign.received = campaign.received + msg.value;
        donorHistory.addToHistory(msg.value,index,msg.sender);
        campaignDonorsList.addDonorToCampaign(index,msg.value,msg.sender);
        if(campaign.received>=campaign.target){
            campaign.completed = true;
        }
    } 
    function updateCampaign(uint index,string memory _title, string memory _description, string memory _imageUrl, uint _target, string memory _deadline) public {
        require(index<campaigns.length,"Invalid campaign index");
        Campaign storage campaign = campaigns[index];
        campaign.title = _title;
        campaign.description = _description;
        campaign.imageUrl = _imageUrl;
        campaign.deadline = _deadline;
        campaign.target = _target;
        if(campaign.received>=campaign.target){
            campaign.completed = true;
        }
        else{
            campaign.completed = false;
        }
    }
}