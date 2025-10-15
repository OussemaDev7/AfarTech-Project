package com.projet.Afar.Entity;

import jakarta.persistence.*;

import java.util.Date;
import java.util.List;

@Entity
public class Client {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
    private Date createdAt;
    private Date updatedAt;
    private Date lastLogin;
    private String image;
    @OneToMany
    private List<Notification> notifications;
    @ManyToMany
    private List<Product> productsBought;
    private Double totalMoneySpent;
    private Date birthDate;
    @ManyToMany
    private List<Product> cart;
    @OneToMany
    private List<Product> favorites;
    private String loyaltyTier;
    @OneToOne
    private Location location;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Date getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(Date lastLogin) {
        this.lastLogin = lastLogin;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<Notification> notifications) {
        this.notifications = notifications;
    }

    public List<Product> getProductsBought() {
        return productsBought;
    }

    public void setProductsBought(List<Product> productsBought) {
        this.productsBought = productsBought;
    }

    public Double getTotalMoneySpent() {
        return totalMoneySpent;
    }

    public void setTotalMoneySpent(Double totalMoneySpent) {
        this.totalMoneySpent = totalMoneySpent;
    }

    public Date getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(Date birthDate) {
        this.birthDate = birthDate;
    }

    public List<Product> getCart() {
        return cart;
    }

    public void setCart(List<Product> cart) {
        this.cart = cart;
    }

    public List<Product> getFavorites() {
        return favorites;
    }

    public void setFavorites(List<Product> favorites) {
        this.favorites = favorites;
    }

    public String getLoyaltyTier() {
        return loyaltyTier;
    }

    public void setLoyaltyTier(String loyaltyTier) {
        this.loyaltyTier = loyaltyTier;
    }

    public Location getLocation() {
        return location;
    }

    public void setLocation(Location location) {
        this.location = location;
    }
}
