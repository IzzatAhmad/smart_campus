/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;
 
public class Summons {
 
    private String summonsId;
    private String summonsDate;
    private String summonsType;     // VEHICLE or MISCONDUCT
    private String offenseId;
    private String offenseName;     // for display
    private String description;
    private double amount;
    private String status;          // UNPAID, PAID, APPEALED, OVERDUE
    private String location;
    private String plateNumber;     // for VEHICLE type
    private String matricNo;        // for MISCONDUCT type
    private String patrolStaffId;
    private String patrolStaffName; // for display
    private String evidencePath;    // evidence image path
    private String createdAt;
    private String updatedAt;
 
    // ── Constructor Empty ──
    public Summons() {}
 
    // ── Constructor Full ──
    public Summons(String summonsId, String summonsDate, String summonsType,
                   String offenseId, String description, double amount,
                   String status, String location, String plateNumber,
                   String matricNo, String patrolStaffId, String createdAt) {
        this.summonsId     = summonsId;
        this.summonsDate   = summonsDate;
        this.summonsType   = summonsType;
        this.offenseId     = offenseId;
        this.description   = description;
        this.amount        = amount;
        this.status        = status;
        this.location      = location;
        this.plateNumber   = plateNumber;
        this.matricNo      = matricNo;
        this.patrolStaffId = patrolStaffId;
        this.createdAt     = createdAt;
    }
 
    // ── Getters ──
    public String getSummonsId()       { return summonsId; }
    public String getSummonsDate()     { return summonsDate; }
    public String getSummonsType()     { return summonsType; }
    public String getOffenseId()       { return offenseId; }
    public String getOffenseName()     { return offenseName; }
    public String getDescription()     { return description; }
    public double getAmount()          { return amount; }
    public String getStatus()          { return status; }
    public String getLocation()        { return location; }
    public String getPlateNumber()     { return plateNumber; }
    public String getMatricNo()        { return matricNo; }
    public String getPatrolStaffId()   { return patrolStaffId; }
    public String getPatrolStaffName() { return patrolStaffName; }
    public String getEvidencePath()    { return evidencePath; }
    public String getCreatedAt()       { return createdAt; }
    public String getUpdatedAt()       { return updatedAt; }
 
    // ── Setters ──
    public void setSummonsId(String summonsId)           { this.summonsId = summonsId; }
    public void setSummonsDate(String summonsDate)       { this.summonsDate = summonsDate; }
    public void setSummonsType(String summonsType)       { this.summonsType = summonsType; }
    public void setOffenseId(String offenseId)           { this.offenseId = offenseId; }
    public void setOffenseName(String offenseName)       { this.offenseName = offenseName; }
    public void setDescription(String description)       { this.description = description; }
    public void setAmount(double amount)                 { this.amount = amount; }
    public void setStatus(String status)                 { this.status = status; }
    public void setLocation(String location)             { this.location = location; }
    public void setPlateNumber(String plateNumber)       { this.plateNumber = plateNumber; }
    public void setMatricNo(String matricNo)             { this.matricNo = matricNo; }
    public void setPatrolStaffId(String patrolStaffId)   { this.patrolStaffId = patrolStaffId; }
    public void setPatrolStaffName(String patrolStaffName){ this.patrolStaffName = patrolStaffName; }
    public void setEvidencePath(String evidencePath)     { this.evidencePath = evidencePath; }
    public void setCreatedAt(String createdAt)           { this.createdAt = createdAt; }
    public void setUpdatedAt(String updatedAt)           { this.updatedAt = updatedAt; }
 
    @Override
    public String toString() {
        return "Summons{" +
               "summonsId='"   + summonsId   + '\'' +
               ", type='"      + summonsType + '\'' +
               ", offenseId='" + offenseId   + '\'' +
               ", amount="     + amount      +
               ", status='"    + status      + '\'' +
               '}';
    }
}
