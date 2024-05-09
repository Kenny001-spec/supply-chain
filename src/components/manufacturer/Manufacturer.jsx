"use client";
import React, { useState } from "react";

const Manufacturer = () => {
  const [productName, setProductName] = useState("");
  const [description, setDescription] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Product Name:", productName);
    console.log("Description:", description);
    // You can reset the form fields after submission
    setProductName("");
    setDescription("");
  };

  return (
    <div className="flex justify-center items-center h-screen">
      <div className="max-w-md w-full p-6 bg-gray-100 rounded-md shadow-lg">
        <h1 className="text-3xl font-bold mb-8 text-center">Create Product</h1>
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label
              htmlFor="productName"
              className="block text-gray-700 font-bold mb-2"
            >
              Product Name:
            </label>
            <input
              type="text"
              id="productName"
              name="productName"
              value={productName}
              onChange={(e) => setProductName(e.target.value)}
              required
              className="block w-full pl-2 border-gray-300  shadow-sm outline-none focus:ring-indigo-500 sm:text-sm focus:border-blue-500"
            />
          </div>
          <div className="mb-4">
            <label
              htmlFor="description"
              className="block text-gray-700 font-bold mb-2"
            >
              Description:
            </label>
            <textarea
              id="description"
              name="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
              rows="4"
              className="block w-full pl-2 border-gray-300 outline-none  shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm focus:border-blue-500"
            />
          </div>
          <button
            type="submit"
            className="bg-blue-500 hover:bg-blue-600 outline-none text-white py-2 px-4 rounded w-full"
          >
            Create Product
          </button>
        </form>
      </div>
    </div>
  );
};

export default Manufacturer;
