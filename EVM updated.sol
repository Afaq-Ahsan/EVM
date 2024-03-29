
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
contract EVM{//Electronic Voting Machine

using Counters for Counters.Counter; 

    Counters.Counter public _candidate_Ids;  
    Counters.Counter public _total_voters; //for counting items sold



//####################### * State variables * ##########################

    address[] Owner;   //Owner's array           
    uint public ownersCount = 0; 
    uint public start_time;
    uint public end_time;
    uint public winers_id;
    string name;
    mapping(address => bool)public isOwner; //no of owners
    mapping(address => mapping(address => bool)) public approved_by_owner; //approve candidate
    mapping(address => uint) private candidate_vote_count; 
    mapping(address => bool)public candidate_added;      //cadidate approved or not
    mapping(address => bool)public vote_casted;
    uint256 public No_Of_Winners;
    
    
    struct CandidateInfo{
        uint id;
        uint256 cnic;
        string  name;
        string education;
        string symbol;
        address addr;
        bool approved;       //if all 3 owners approve this cadidate then it will be added
        uint no_approvals;    //no of approvals 
        bool already_listed;
        uint256 votes_count;
    }

    struct voterInfo{
      uint id;
      uint256 cnic;
      string name;
      string vote_gives_for;
      address _address;
      bool votecasted;
    }

    mapping(uint=>CandidateInfo) public _CandidateInfo;
    mapping(uint=>voterInfo)public _votersInfo;
    mapping(uint=>uint)private candidate_get_votes;
    mapping(address=>bool)private waiting_for_appr;
    mapping(uint256=> bool)public voters_cnic;
    mapping(uint256=> bool)public Candidate_cnic;
    CandidateInfo[] private CandidateConfirmed;
    uint no_Requests;
   address[] Winners = new address[](No_Of_Winners);
    


    error revertedError(string);
    event notapprove(string);

//####################### * Constructor * ##########################

    constructor(){

        Owner.push(msg.sender);
        isOwner[msg.sender] = true;
        ownersCount+=1;
        name = "EVM";
        // start_time = block.timestamp;
        // end_time = block.timestamp + 24 hours;

    }


    modifier onlyOwner(){
        require(isOwner[msg.sender] == true,"only owner can call this function");
        _;
    }

    function getOwners()public view returns(address[]memory){
       return Owner;
    }

//####################### * add new Owner * ##########################

    function addNewOwner(address newowner)public onlyOwner{
      require(!isOwner[newowner],"already added in owners list"); 
      require(Owner.length <3 ,"you can add only 3 owners"); 
      isOwner[newowner] = true;
      Owner.push(newowner);
      ownersCount+=1;
    }



    
//####################### * Request to approve a candidate * ##########################
    
    function Request_to_appr(uint256 _cnic, string memory _name,string memory _education,string memory _symbol,address _addr)public onlyOwner{
      require(!isOwner[_addr],"Owner cannot be a candidate");
       require(Owner.length >=2,"should have atleast 2 owners");
       require(!candidate_added[_addr],"already listed as EVM cadidate");
       require(!approved_by_owner[msg.sender][_addr],"you already approve this candidate");
       require(!waiting_for_appr[_addr],"already waiting for approvals");
       require(!Candidate_cnic[_cnic],"CNIC No is already added");
      
       uint _id = _candidate_Ids.current();
       
       approved_by_owner[msg.sender][_addr] = true;
       _CandidateInfo[_id].id =  _id;
       _CandidateInfo[_id].cnic = _cnic;
       _CandidateInfo[_id].name = _name;
       _CandidateInfo[_id].education = _education;
       _CandidateInfo[_id].symbol = _symbol;
       _CandidateInfo[_id].addr= _addr;
       _CandidateInfo[_id].approved = false;
       _CandidateInfo[_id].no_approvals += 1;
       _CandidateInfo[_id].already_listed = true;  
       waiting_for_appr[_addr] = true;
       Candidate_cnic[_cnic] = true;
       _candidate_Ids.increment();        
    }

//####################### * Approve that candidate * ##########################

    function approve(uint _id)public onlyOwner{
        require(_CandidateInfo[_id].addr != address(0),"first need request to approve");
        require(_CandidateInfo[_id].approved == false,"already approved"); //it means whether all 3 members approveed it or not
        require(_CandidateInfo[_id].no_approvals < 3,"all 3 Owners approved");
        address add = _CandidateInfo[_id].addr;
        require(!approved_by_owner[msg.sender][add],"already approved by you");
        
        approved_by_owner[msg.sender][add] = true;
        _CandidateInfo[_id].no_approvals +=1;
       
        console.log("total approval is",_CandidateInfo[_id].no_approvals);
        if(_CandidateInfo[_id].no_approvals == 3){
             _CandidateInfo[_id].approved = true;

          console.log("enter in if");
           addCandidate(
               _CandidateInfo[_id].cnic,
               _CandidateInfo[_id].id,
               _CandidateInfo[_id].name,
               _CandidateInfo[_id].education,
               _CandidateInfo[_id].symbol,
               _CandidateInfo[_id].addr,
               _CandidateInfo[_id].approved,
               _CandidateInfo[_id].no_approvals
           );
        }
        else{
            _CandidateInfo[_id].approved = false;
            console.log("enter in else");

            emit notapprove("error not approve from all Owners"); 
        }
    }

//####################### * Add a new Candidate * ##########################

    function addCandidate(uint _id,uint256 _cnic, string memory _name,string memory _education,string memory _symbol,address _addr,bool _approved,uint no_appr)private{   
        // require( _CandidateInfo[_id].no_approvals == 3,"need to approve from all 3 owners");
            _CandidateInfo[_id].cnic = _cnic;
            _CandidateInfo[_id].name = _name;
            _CandidateInfo[_id].education = _education;
            _CandidateInfo[_id].symbol = _symbol;
            _CandidateInfo[_id].addr = _addr;
            _CandidateInfo[_id].approved = _approved;
            _CandidateInfo[_id].no_approvals = no_appr;
            _CandidateInfo[_id].votes_count = VotesGot(_addr);

            candidate_added[_addr]=true;
            CandidateConfirmed.push(
                CandidateInfo({
                    id:_id,
                    cnic : _cnic,
                    name : _name,
                    education : _education,
                    symbol : _symbol,
                    addr : _addr,
                    approved : _approved,
                    no_approvals : no_appr,
                    already_listed : _approved,
                    votes_count :  _CandidateInfo[_id].votes_count
                })
            );
        }

//####################### * Cast vote * ##########################
   bool started;
   bool ended;
   function start()public onlyOwner{
    require(!started,"Voting is already started");
    require(CandidateConfirmed.length >= 2 , "voting only starts if there is 2 or more candidates");
    started = true;
    end_time = block.timestamp + 86400;
    }
    
    function end()public onlyOwner{
        require(started,"voting is not started yet");
        require(!ended,"already ended");
    ended = true;
    }

 
    function Vote(uint256 _cnic,string memory _name,string memory vote_to,uint256 id)public{
        require(started,"not started");
        require(!ended,"voting ended");
        require(!voters_cnic[_cnic] && !vote_casted[msg.sender],"already vote casted");
        require(block.timestamp < end_time,"voting is not on going");
        uint _id = _total_voters.current();
        
        require(_CandidateInfo[id].approved == true,"candidate not approved yet");
         _votersInfo[_id].id = _id;
         _votersInfo[_id].name = _name;
         _votersInfo[_id].cnic = _cnic;
         _votersInfo[_id].vote_gives_for = vote_to;
         _votersInfo[_id]._address = msg.sender;
         _votersInfo[_id].votecasted = true;
        //  candidate_vote_count[_candidate_address]+=1;
         candidate_get_votes[id]+=1;
         _CandidateInfo[id].votes_count +=1;
         _total_voters.increment();
         vote_casted[msg.sender] = true;
         voters_cnic[_cnic] = true;
        } 

    function calculate_Results()public returns(uint,uint){
        require(ended,"first end the voting session");
        uint max;
     
     for(uint i=0;i<_candidate_Ids.current();i++){
        uint a = _CandidateInfo[i].id;
        uint b = _CandidateInfo[i+1].id;
     
      if(_CandidateInfo[a].votes_count >_CandidateInfo[b].votes_count){
          max = a;
      }
      else{
          max = b;
      }
     }
     winers_id = _CandidateInfo[max].id;
     No_Of_Winners+=1;
     Winners.push(_CandidateInfo[max].addr);

     return(_CandidateInfo[max].id,_CandidateInfo[max].votes_count);
    }

    function get_Winners_Detail()public view returns(CandidateInfo memory){
        return _CandidateInfo[winers_id];
    }

//####################### * Address of Candidate * ##########################

        function address_candidate(uint _id)public view returns(address){ //get the address of candidate
          return  _CandidateInfo[_id].addr;
        }        

        function VotesGot(address _addr)private view returns(uint256){ // get how much votes candidate got
           return candidate_vote_count[_addr];
        }

//####################### * Number of Candidates * ##########################

        function candidates()public view returns(uint){ // how muny number of candidates are there
          return  CandidateConfirmed.length;
        }

//####################### * get Candidate Name * ##########################

        function getCandidateNames(uint _id)public view returns(string memory){
              return  _CandidateInfo[_id].name;
        }

//####################### * get Candidate Symbol * ##########################

        function getCandidateSymbol(uint _id)public view returns(string memory){
              return  _CandidateInfo[_id].symbol;
        }

//####################### * Votes get by a Candidate * ##########################

        function votesget(uint _id)public view returns(uint256){
        return candidate_get_votes[_id];
        }

         function getName()public view returns(string memory){
            return name;
        }

}
