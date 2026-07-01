/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class Vehicle {
    private String vehicleId;
    private String studentId;
    private String vehicleType; // CAR / MOTORCYCLE
    private String plateNumber;
    private String brand;
    private String color;
    private String engineCC;
    private String grantImagePath;
    private String status; // PENDING/APPROVED/REJECTED
    private String clerkComment;
    // Enriched from student JOIN (not stored in vehicle table)
    private String studentName;
    private String matricNo;

    public Vehicle() {}

    // getters/setters
    public String getVehicleId() { return vehicleId; }
    public void setVehicleId(String vehicleId) { this.vehicleId = vehicleId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getVehicleType() { return vehicleType; }
    public void setVehicleType(String vehicleType) { this.vehicleType = vehicleType; }

    public String getPlateNumber() { return plateNumber; }
    public void setPlateNumber(String plateNumber) { this.plateNumber = plateNumber; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getEngineCC() { return engineCC; }
    public void setEngineCC(String engineCC) { this.engineCC = engineCC; }

    public String getGrantImagePath() { return grantImagePath; }
    public void setGrantImagePath(String grantImagePath) { this.grantImagePath = grantImagePath; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getClerkComment() { return clerkComment; }
    public void setClerkComment(String clerkComment) { this.clerkComment = clerkComment; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getMatricNo() { return matricNo; }
    public void setMatricNo(String matricNo) { this.matricNo = matricNo; }
}