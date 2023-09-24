// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateVerification{
    address public owner;
    struct Certificate{
        string universityName;
        string hash;
        string registrationNumber;
    }

    struct Registrar{
        string universityName;
        address registrarAddress;
    }

    mapping(address => Registrar) public registrar;
    mapping(string => mapping(address => Registrar)) public registrars; //mapping of univName to address of registrar
    mapping(string => mapping(string => Certificate)) public certificate;//mapping of univName to registration number
    mapping(string => mapping(address => bool)) public isRegistrar;
    mapping(string => mapping(string => bool)) public isAdded;//mapping of univName to registration number

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner,"Only owner can access this feature");
        _;
    }

    function assignRegistrar(string calldata _universityName, address _address) public onlyOwner{
        isRegistrar[_universityName][_address] = true;
        Registrar memory newRegistrar = Registrar({
            universityName:_universityName,
            registrarAddress:_address
        });
        registrars[_universityName][_address] = newRegistrar;
        registrar[_address] = newRegistrar;
    }

    function isAddressRegistrar(address _address) public view returns (bool) {
        return isRegistrar[registrar[_address].universityName][_address];
    }


    function getRegistrar(address _address) public view returns(Registrar memory){
        Registrar storage _registrar = registrar[_address];
        return _registrar;
    }

    function isOwner(address _address) public view returns (bool){
        if(_address == owner){
            return true;
        }
        return false;
    }

    function addCertificate(string calldata _universityName, string calldata _registrationNumber, string calldata _hash) public {
        require(!isAdded[_universityName][_registrationNumber],"Student already added");
        Registrar storage _registrar = registrars[_universityName][msg.sender];
        bool isValid = compareStrings(_registrar.universityName,_universityName);
        require(isValid,"Please add only certificates that belong to your unviersity");
        Certificate memory newCertificate = Certificate({
            universityName:_universityName,
            hash:_hash,
            registrationNumber:_registrationNumber
        });
        certificate[_universityName][_registrationNumber] = newCertificate;
        isAdded[_universityName][_registrationNumber] = true;
    }

    function compareStrings(string memory a, string memory b) public pure returns(bool){
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function getCertificate(string calldata _universityName, string calldata _registrationNumber) public view returns(Certificate memory){
        Certificate storage _certificate = certificate[_universityName][_registrationNumber];
        return _certificate;
    }

}